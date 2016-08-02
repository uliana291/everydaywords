class TrainingsController < ApiController
  require 'json'

  def add
    training = Training.new
    training.kind = 'daily'
    training.state = 'new'
    training.user = current_user
    if params[:json_data]
      training.json_data = params[:json_data].to_json
      training.save
    else
      if !manual_json(training)
        training = nil
      else
        training.save
      end
    end
    if !training
      render :json => {:error => 'internal-server-error'}, :status => 500
    else
      render :json => {:result => {'status' => 'ok', 'id' => training.id}}, :status => 200
    end
  end

  def destroy
    training = Training.find_by(id: params[:id])
    if !training
      render :json => {:error => 'not-found'}, :status => 500
    else
      training.destroy
      training = Training.find_by(id: params[:id])
      if !training
        render :json => {:status => 'ok'}, :status => 200
      else
        render :json => {:error => 'internal-server-error'}, :status => 500
      end
    end
  end


  def list
    trainings = Training.where(:kind => 'daily', :user_id => current_user.id).sort_by(&:created_at).reverse
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
      trainingEl = {'id' => training.id,
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
        render :json => {:result => {'status' => 'ok', 'id' => training.id}}, :status => 200
      end
    end
  end

  def finish_daily
    training = Training.find_by(:id => params[:id])
    if !training
      render :json => {:error => 'training is not found'}, :status => 500
    else
      training.state = 'finished'
      training_history = []
      json_data = JSON.parse(training.json_data)
      lastTrainDate = nil
      if json_data['training_history']
        json_data['training_history'].each do |el|
          training_history.push(el['results'])
          lastTrainDate = (lastTrainDate.nil? ? el['when'].to_datetime : [lastTrainDate.to_datetime, el['when'].to_datetime].max)
          puts lastTrainDate
        end
        if lastTrainDate
          training_history.flatten!
          tId = {}
          training_history.each do |h|
            tId[h['user_translation_id']] ||= []
            tId[h['user_translation_id']] << h['answer']
          end
          json_data['training_results'] = []
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
            training_history = JSON.parse(uTranslation.training_history)
            training_history.push([{'when' => time,
                                    'previous_stage' => uTranslation.learning_stage,
                                    'new_stage' => newStage,
                                    'training_state' => 'daily'}])
            json_data['training_results'].push({'user_translation_id' => uTranslation.id,
                                                 'previous_learning_stage' => uTranslation.learning_stage,
                                                 'new_learning_stage' => newStage})
            training.json_data = json_data.to_json
            uTranslation.learning_stage = newStage
            uTranslation.training_history = training_history.to_json
            uTranslation.next_training_at = (percent == 1 ? get_next_training_time(uTranslation.learning_stage, lastTrainDate) : (lastTrainDate+1).to_s)
            uTranslation.save
            training.save
            if !uTranslation || !training
              render :json => {:error => 'internal-server-error'}, :status => 500
            end
          end
          render :json => {:status => 'ok'}, :status => 200
        else
          render :json => {:error => 'internal-server-error'}, :status => 500
        end
      else
        render :json => {:error => 'internal-server-error'}, :status => 500
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
      when '1', '2'
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
      when '1', '2', '7'
        newStage = '1'
      when '14'
        newStage = '2'
      when '30'
        newStage = '7'
    end
    newStage
  end


  def get_next_training_time(newStage, date)
    case newStage
      when '1', '2'
        newNextTraining = (date+1).to_s
      when '7'
        newNextTraining = (date+7).to_s
      when '14'
        newNextTraining = (date+14).to_s
      when '30'
        newNextTraining = (date+30).to_s
      when 'finished'
        newNextTraining = nil
    end
    newNextTraining
  end

  def manual_json(training)
    if current_user.day_words != nil
      user_translations = current_user.user_translations.where('next_training_at<= ?', Date.today)
                              .pluck(:id).sample(current_user.day_words)
      json_data = {:name => 'new training '+Time.now.iso8601, :user_translation_id_list => user_translations}.to_json
      training.json_data = json_data
      training
    else
      nil
    end
  end

end
