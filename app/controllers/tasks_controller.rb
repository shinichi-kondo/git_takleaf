class TasksController < ApplicationController
  before_action :set_task, only: [:show, :edit, :update, :destroy]
  
  def index
    @q = current_user.tasks.ransack(params[:q])
    @tasks = @q.result(distinct: true).page(params[:page])
    
    respond_to do |format|
      format.html
      format.csv { send_data @tasks.generate_csv, filename: "tasks-#{Time.zone.now.strftime('%Y%m%d%d%S')}.csv"}
    end
  end

  def show
  end

  def new
    @task = Task.new
  end

  def edit
  end
  
  def create
    @task = current_user.tasks.new(task_params)
    
    if params[:back].present?
      render :new
      return
    end
    
    if @task.save
      TaskMailer.creation_email(@task).deliver_now
      redirect_to @task, notice: "タスク「#{@task.name}」を登録しました。"
    else
      render :new
    end
  end
  
  def update
    @task.update!(task_params)
    redirect_to tasks_url, notice: "タスク「#{@task.name}」を更新しました。"
  end
  
  def destroy
    @task.destroy
    redirect_to tasks_url, notice: "タスク「#{@task.name}」を削除しました。"
  end
  
  def confirm_new
    @task = current_user.tasks.new(task_params)
    render :new unless @task.valid?
  end
  
  def import
    if params[:csv_file].blank?
      redirect_to tasks_url, notice: '読み込むCSVを選択してください'
    else
      current_user.tasks.import(params[:file])
      redirect_to tasks_url, notice: "タスクを追加しました"
    end  
  end  
  
  private
  
  def task_params
    params.require(:task).permit(:name, :description, :image)
  end
  
  def set_task
    @task = current_user.tasks.find(params[:id])
  end
end  
