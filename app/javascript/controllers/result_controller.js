import { Controller } from "@hotwired/stimulus"
import consumer from "../channels/consumer"
import * as bootstrap from "bootstrap"

const escapeHtml = (unsafe) => {
  if (!unsafe) return '' // nullやundefinedの場合は空文字を返す
  return unsafe
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#039;");
}

export default class extends Controller {
  static values = {
    roomId: Number,
    currentUserId: Number,
    currentGuestId: String,
    initial: String,
  }
  static targets = ["resultsWrapper", "rankingContainer"]

  connect() {
    const initialData = JSON.parse(this.initialValue)
    this.updateRanking(initialData.ranked_results, initialData.all_words_evaluated)

    this.subscription = consumer.subscriptions.create(
      { channel: "ResultChannel", room_id: this.roomIdValue },
      {
        received: (data) => {
          if (data.event === 'update_results') {
            this.updateRanking(data.ranked_results, data.all_words_evaluated)
          }
        }
      }
    )
  }

  updateRanking(rankedResults, allWordsEvaluated) {
    const loadingMessage = document.getElementById('initial-loading-message')
    if (loadingMessage) {
      loadingMessage.remove()
    }

    this.rankingContainerTarget.innerHTML = ''

    rankedResults.forEach((resultData, index) => {
      const rank = index + 1
      const cardId = `participant-${resultData.participant_id}`
      const cardElement = this.createRankingCard(cardId, resultData, rank)
      this.rankingContainerTarget.appendChild(cardElement)
    })
    
    const accordions = this.rankingContainerTarget.querySelectorAll('.accordion-button')
    accordions.forEach(button => {
      const targetSelector = button.dataset.bsTarget
      const collapseTarget = document.querySelector(targetSelector)
      if (collapseTarget) {
        new bootstrap.Collapse(collapseTarget, { toggle: false })
      }
    })

    if (allWordsEvaluated) {
      this.finalizeResults(rankedResults)
    }
  }

  createRankingCard(cardId, data, rank) {
    const cardWrapper = document.createElement('div')
    cardWrapper.id = cardId
    cardWrapper.classList.add('row', 'justify-content-center', 'mb-4')
    
    const isCurrentUser = this.isCurrentUser(data)
    const aiScore = data.total_ai_score ?? '???'
    const chainBonusScore = data.total_chain_bonus_score ?? '???'

    // ▼▼▼ レビュー指摘箇所を修正 ▼▼▼
    // 全ての動的コンテンツを escapeHtml ヘルパーで囲む
    const wordsHistoryHtml = data.words.map(word => `
      <div class="d-flex justify-content-between align-items-center mb-2 pb-2 border-bottom">
        <div class="flex-grow-1 text-start">
          <p class="fs-6 mb-0 fw-medium">${escapeHtml(word.body)}</p>
          ${word.ai_evaluation_comment ? `
            <div class="text-muted small mt-1 p-2 bg-light rounded">
              <i class="bi bi-robot me-1"></i>
              ${escapeHtml(word.ai_evaluation_comment)}
            </div>
          ` : ''}
          ${word.chain_bonus_comment ? `
            <div class="text-muted small mt-1 p-2 bg-success bg-opacity-10 rounded">
              <i class="bi bi-link-45deg me-1"></i>
              ${escapeHtml(word.chain_bonus_comment)}
            </div>
          ` : ''}
        </div>
        <div class="text-end ms-3" style="min-width: 140px;">
          ${word.score > 0 ? `
            <span class="badge bg-secondary rounded-pill">基礎: ${word.score}点</span>
            <span class="badge bg-info rounded-pill">AI: ${word.ai_score ?? '...'}点</span>
            ${word.chain_bonus_score ? `<span class="badge bg-success rounded-pill mt-1">連鎖: ${word.chain_bonus_score}点</span>` : ''}
          ` : `<span class="badge bg-light text-muted rounded-pill">開始単語</span>`}
        </div>
      </div>
    `).join('')

    cardWrapper.innerHTML = `
      <div class="col-md-8">
        <div class="card ${isCurrentUser ? 'border-primary' : ''}">
          <div class="card-header d-flex align-items-center justify-content-between">
            <div class="d-flex align-items-center">
              <span class="rank-badge fs-5 me-3">${rank}位</span>
              <h4 class="mb-0">${escapeHtml(data.username)} ${isCurrentUser ? '(あなた)' : ''}</h4>
            </div>
            <span class="crown fs-2 d-none">👑</span>
          </div>
          <div class="card-body text-center">
            <div class="row">
              <div class="col">
                <h3 class="display-5 fw-bold">${data.total_score}</h3>
                <small class="text-muted">総合スコア</small>
              </div>
              <div class="col">
                <h5 class="text-secondary">${data.total_base_score}</h5>
                <small class="text-muted">基礎点</small>
              </div>
              <div class="col">
                <h5 class="text-info">${aiScore}</h5>
                <small class="text-muted">AIボーナス</small>
              </div>
              <div class="col">
                <h5 class="text-success">${chainBonusScore}</h5>
                <small class="text-muted">連鎖ボーナス</small>
              </div>
            </div>
          </div>
          <div class="card-footer">
            <div class="accordion" id="accordion-${cardId}">
              <div class="accordion-item">
                <h2 class="accordion-header">
                  <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#collapse-${cardId}" aria-expanded="false">
                    単語履歴を見る
                  </button>
                </h2>
                <div id="collapse-${cardId}" class="accordion-collapse collapse" data-bs-parent="#accordion-${cardId}">
                  <div class="accordion-body" style="max-height: 300px; overflow-y: auto;">
                    ${wordsHistoryHtml}
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    `
    // ▲▲▲ レビュー指摘箇所を修正 ▲▲▲
    return cardWrapper
  }

  finalizeResults(rankedResults) {
    if (rankedResults.length === 0) return
    const winnerId = `participant-${rankedResults[0].participant_id}`
    const winnerCard = document.getElementById(winnerId)
    if (winnerCard) {
      winnerCard.querySelector('.crown').classList.remove('d-none')
      winnerCard.querySelector('.card').classList.add('border-warning', 'shadow-lg')
    }
  }

  isCurrentUser(data) {
    if (this.currentUserIdValue) {
      return data.user_id === this.currentUserIdValue
    }
    if (this.currentGuestIdValue) {
      return data.guest_id === this.currentGuestIdValue
    }
    return false
  }

  disconnect() {
    this.subscription.unsubscribe()
  }
}