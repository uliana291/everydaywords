module TranslationHelper

  def search_for_unfinished_words(type)
    trainings = Training.where(state: 'new')
    translation_ids = []
    attr = (type.equal?('q_a')? 'user_q_a_list' : 'user_translation_id_list')
    trainings.each do |training|
      json_data = JSON.parse(training.json_data)
      if !(json_data[attr].nil?)
        json_data[attr].each do |id|
          translation_ids.push(id)
        end
      end

    end
    return translation_ids.uniq
  end

end
