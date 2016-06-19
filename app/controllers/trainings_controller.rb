class TrainingsController < ApiController
require 'json'
  def save
    uTranslation = UserTranslation.find(params[:user_translation_id])
    if uTranslation
      currentStage = uTranslation.learning_stage
      newStage = ''
      if params[:answer_result].eql? 'passed'
        case currentStage
          when '1'
            newStage = '2'
          when '2'
            newStage = '7'
          when '7'
            newStage = '14'
          when '14'
            newStage = '30'
          when '30'
            newStage = 'finished'
        end
        uTranslation.learning_stage = newStage
      else
        newStage = '1'
        uTranslation.learning_stage = '1'
      end
      date = Date.today
      case newStage
        when '1','2'
          newNextTraining = (date+1).to_s
        when '7'
          newNextTraining = (date+7).to_s
        when '14'
          newNextTraining = (date+14).to_s
        when '30'
          newNextTraining = (date+30).to_s
        when 'finished'
          newNextTraining = null
      end
      time = DateTime.now.to_s
      training_history = [{'when' => time,
                           'previous_stage' => currentStage,
                           'new_stage' => newStage,
                           'training_state' => params[:answer_result]}]
      uTranslation.next_training_at = newNextTraining
      uTranslation.training_history = training_history.to_s
      if uTranslation.save
        render :json => {:status => 'ok'}, :status => 200
      else
        render :json => {:error => 'internal-server-error'}, :status => 500
      end
    else
      render :json => {:error => 'user translation is not found'}, :status => 500
    end
  end



  def add
    training = Training.new
    training.kind = 'daily'
    training.state = 'new'
    training.user = current_user
    training.json_data = params[:json_data].to_json
    training.save
    if !training
      render :json => {:error => 'internal-server-error'}, :status => 500
    else
      render :json => {:result => { 'status' => 'ok', 'id' => training.id} }, :status => 200
    end
  end


  def list
    trainings = Training.where(:kind => 'daily', :user_id => current_user.id)
    trainingsArr = []
    trainings.each do |t|
      trainingsArr.push('id' => t.id,
                        'state' => t.state,
                        'json_data' => JSON.parse(t.json_data))
    end
    render :json => trainingsArr

  end

  def get
    training = Training.find_by(:id => params[:id])
    if !training
      render :json => {:error => 'training is not found'}, :status => 500
    else
      trainingEl = [ 'id' => training.id,
                     'state' => training.state,
                     'kind' => training.kind,
                     'user_id' => training.user_id,
                     'json_data' => JSON.parse(training.json_data)]
      render :json => trainingEl
    end
  end

  def update
    training = Training.find_by(:id => params[:id])
    if !training
      render :json => {:error => 'training is not found'}, :status => 500
    else
      training.state = params[:state]
      training.json_data = params[:json_data].to_json
      training.save
      if !training
        render :json => {:error => 'internal-server-error'}, :status => 500
      else
        render :json => {:result => { 'status' => 'ok', 'id' => training.id} }, :status => 200
      end
    end
  end






end
