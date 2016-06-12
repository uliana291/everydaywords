class TrainingsController < ApiController

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

end
