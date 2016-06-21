class TrainingsController < ApiController
require 'json'


  def save
    uTranslation = UserTranslation.find(params[:user_translation_id])
    if uTranslation
      currentStage = uTranslation.learning_stage
      if params[:answer_result].eql? 'passed'
        newStage = to_next_stage(currentStage)
        uTranslation.learning_stage = newStage
      else
        newStage = '1'
        uTranslation.learning_stage = '1'
      end
      time = DateTime.now.to_s
      training_history = [{'when' => time,
                           'previous_stage' => currentStage,
                           'new_stage' => newStage,
                           'training_state' => params[:answer_result]}]
      uTranslation.next_training_at = get_next_training_time(newStage)
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
      trainingEl = { 'id' => training.id,
                     'state' => training.state,
                     'kind' => training.kind,
                     'user_id' => training.user_id,
                     'json_data' => JSON.parse(training.json_data)}
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

  def finish_daily
    training = Training.find_by(:id => params[:id])
    if !training
      render :json => {:error => 'training is not found'}, :status => 500
    else
      training.state = 'finished'
      json_data = JSON.parse(training.json_data)
      training_history = []
      json_data['training_history'].each do |el|
        training_history.push(el['results'])
      end
      training_history.flatten!
      tId = {}
      training_history.each do |h|
        tId[h['user_translation_id']] ||= []
        tId[h['user_translation_id']] << h['answer']
      end
      tId.each do |translation, results|
        uTranslation = UserTranslation.find(translation)
        training_count = results.length
        training_passed = 0
        results.each do |r|
          if r == 'passed'
            training_passed += 1
          end
        end
        percent = training_passed.to_f/training_count.to_f
        if percent == 1
          newStage = to_next_stage(uTranslation.learning_stage)
        elsif percent < 1 && percent >= 0.8
          newStage = uTranslation.learning_stage
        elsif percent < 0.8 && percent >= 0.6
          newStage = minus_level(uTranslation.learning_stage)
        elsif percent < 0.6 && percent >= 0.4
          newStage = minus_two(uTranslation.learning_stage)
        else
          newStage = '1'
        end
        time = DateTime.now.to_s
        training_history = [{'when' => time,
                             'previous_stage' => uTranslation.learning_stage,
                             'new_stage' => newStage,
                             'training_state' => (newStage == 'passed'? 'passed' : 'dont_know')}]
        uTranslation.learning_stage = newStage
        uTranslation.training_history = training_history.to_s
        uTranslation.next_training_at = (percent == 1? get_next_training_time(uTranslation.learning_stage) : (Date.today+1).to_s)
        uTranslation.save
        if uTranslation.save
          render :json => {:status => 'ok'}, :status => 200
        else
          render :json => {:error => 'internal-server-error'}, :status => 500
        end
      end
    end
  end


  private

  def to_next_stage(currentStage)
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
    newStage
  end

  def minus_level(currentStage)
    case currentStage
      when '1','2'
        newStage = '1'
      when '7'
        newStage = '2'
      when '14'
        newStage = '7'
      when '30'
        newStage = '14'
    end
    newStage
  end


  def minus_two(currentStage)
    case currentStage
      when '1','2','7'
        newStage = '1'
      when '14'
        newStage = '2'
      when '30'
        newStage = '7'
    end
    newStage
  end


  def get_next_training_time(newStage)
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
    newNextTraining
  end


end
