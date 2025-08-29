class RoomsController < ApplicationController
  # MVPでは show, index, create 以外は不要なので before_action は一旦削除します

  def index
    # indexアクションはトップページ表示のため、中身は空のままでOK
  end

  def show
    @room = Room.find(params[:id])
  end

  def create
    @room = Room.new
    @room.words.build(body: 'しりとり')

    if @room.save
      redirect_to @room, notice: "ゲーム開始！"
    else
      # もし保存に失敗したらトップページに戻る
      render :index, status: :unprocessable_entity
    end
  end

  # MVPでは new, edit, update, destroy, privateメソッドは不要なので、ここから下はすべて削除します
end