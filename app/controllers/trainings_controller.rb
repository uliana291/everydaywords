class TrainingsController < ApiController
  include TranslationHelper
  require 'json'

  def add_daily
    if current_user.user_translations.length > 0
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
    else
      render :json => {:error => '0 words'}, :status => 500
    end
  end

  def add_qa
    training = Training.new
    training.kind = params[:group_name]
    training.state = 'new'
    training.user = current_user
    if !manual_json(training, qa: true)
      training = nil
    else
      training.save
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
    trainings = Training.where(:kind => (params[:group_name].nil? ? 'daily' : params[:group_name]),
                               :user_id => current_user.id).sort_by(&:created_at).reverse
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
      json_data = JSON.parse(training.json_data)
      trainingEl = {'id' => training.id,
                    'state' => training.state,
                    'kind' => training.kind,
                    'user_id' => training.user_id,
                    'json_data' => json_data}
      if !params[:get_qa].nil?
        qa_list = []
        json_data['user_q_a_list'].each do |el|
          user_qa = UserQa.find(el)
          qa = user_qa.qa
          qa_attr = qa.attributes.slice('id', 'json_data')
          qa_attr['json_data'] = JSON.parse(qa_attr['json_data'])
          qa_attr['user_qa_id'] = user_qa.id
          qa_list.push(qa_attr)
        end
        trainingEl['qa_list'] = qa_list
      end
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

  def finish_qa
    finish('qa')
  end

  def finish_daily
    finish('daily')
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


  def selection_with_criteria(user_translations)
    result = []
    remained = current_user.day_words
    expressions = (remained * 0.2).to_int
    almost_finished = user_translations.where(learning_stage: '30').order(:updated_at).limit((remained * 0.3).to_int)
    result += almost_finished.pluck(:id)
    remained -= result.count
    user_translations.where.not(id: result).each do |us_tr|
      if us_tr.translation.original.value.include? ' '
        result.append(us_tr.id)
        remained -= 1
        expressions -= 1
        if expressions == 0
          break
        end
      end
    end
    frequent_words = []
    user_translations.where.not(id: result).order(:updated_at).each do |us_tr|
      f = Frequency.find_by(word: us_tr.translation.original.value)
      if f == nil
        frequent_words.append({id: us_tr.id, freq: -1})
      else
        frequent_words.append({id: us_tr, freq: f.frequency})
      end
    end
    frequent_words.sort_by! { |hsh| hsh[:freq] }.reverse!
    frequent_words_ids = frequent_words.map { |word| word[:id]}
    result += frequent_words_ids.first(remained)
    return result
  end


  def manual_json(training, qa=nil)
    if current_user.day_words != nil
      if qa.nil?
        unfinished_words = search_for_unfinished_words('user')
        user_translations = current_user.user_translations.where('next_training_at<= ?', Date.today)
                                .where.not(id: unfinished_words)
        if user_translations.count <= current_user.day_words
          ut_list = user_translations.pluck(:id).sample(current_user.day_words)
        else
          ut_list = selection_with_criteria(user_translations)
        end
        json_data = {:name => Time.now.iso8601, :user_translation_id_list => ut_list}.to_json
        training.json_data = json_data
        training
      else
        group = QaGroup.where(name: params[:group_name]).first()
        unfinished_qa = search_for_unfinished_words('q_a')
        q_a_random = Qa.all.where(qa_group: group).where.not(id: unfinished_qa).pluck(:id).sample(current_user.day_words)
        d = Date.today
        user_qa_list = []
        q_a_random.each do |q_a|
          qa = Qa.find(q_a)
          user_where_qa = UserQa.all.where(qa: qa)
          if user_where_qa.length > 0
            user_qa = user_where_qa.first
          else
            user_qa = UserQa.new
            user_qa.qa = qa
            user_qa.user = current_user
            user_qa.learning_stage = '1'
            user_qa.next_training_at = (d+1).to_s
            user_qa.training_history = [{when: d.to_s, next_stage: '1'}].to_json
            if !user_qa.save
              return nil
            end
          end
          user_qa_list.push(user_qa.id)
        end
        json_data = {:name => Time.now.iso8601, :user_q_a_list => user_qa_list}.to_json
        training.json_data = json_data
        training
      end
    else
      nil
    end
  end


  def finish(type)
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
          attr = (type.eql?('qa') ? 'user_q_a_id' : 'user_translation_id')
          training_history.each do |h|
            tId[h[attr]] ||= []
            tId[h[attr]] << h['answer']
          end
          json_data['training_results'] = []
          tId.each do |item, results|
            element = (type.eql?('qa') ? UserQa.find(item) : UserTranslation.find(item))
            training_count = results.length
            training_passed = 0
            results.each do |r|
              if r == 'passed'
                training_passed += 1
              end
            end
            percent = training_passed.to_f/training_count.to_f
            if percent == 1
              newStage = to_next_stage(element.learning_stage)
            elsif percent < 1 && percent >= 0.8
              newStage = element.learning_stage
            elsif percent < 0.8 && percent >= 0.6
              newStage = minus_level(element.learning_stage)
            elsif percent < 0.6 && percent >= 0.4
              newStage = minus_two(element.learning_stage)
            else
              newStage = '1'
            end
            time = DateTime.now.to_s
            training_history = JSON.parse(element.training_history)
            training_history.push([{'when' => time,
                                    'previous_stage' => element.learning_stage,
                                    'new_stage' => newStage,
                                    'training_state' => (type.equal?('qa') ? 'question_answer' : 'daily')}])
            json_data['training_results'].push({'user_translation_id' => element.id,
                                                'previous_learning_stage' => element.learning_stage,
                                                'new_learning_stage' => newStage})
            training.json_data = json_data.to_json
            element.learning_stage = newStage
            element.training_history = training_history.to_json
            element.next_training_at = (percent == 1 ? get_next_training_time(element.learning_stage, lastTrainDate) : (lastTrainDate+1).to_s)
            element.save
            training.save
            if !element || !training
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

end
