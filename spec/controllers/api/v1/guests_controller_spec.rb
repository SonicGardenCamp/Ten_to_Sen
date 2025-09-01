require 'rails_helper'

RSpec.describe Api::V1::GuestsController, type: :controller do
  describe 'POST #create' do
    it 'creates a guest and sets encrypted cookies' do
      post :create, params: { name: 'ゲスト太郎' }
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)['guest_name']).to eq('ゲスト太郎')
      expect(cookies.encrypted[:guest_id]).to be_present
      expect(cookies.encrypted[:guest_name]).to eq('ゲスト太郎')
    end

    it 'defaults guest name if not provided' do
      post :create
      expect(JSON.parse(response.body)['guest_name']).to eq('ゲスト')
      expect(cookies.encrypted[:guest_name]).to eq('ゲスト')
    end
  end
end
