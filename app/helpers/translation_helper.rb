module TranslationHelper

  def search_for_unfinished_words
    trainings = Training.where(state: 'new')
    translation_ids = []
    trainings.each do |training|
      json_data = JSON.parse(training.json_data)
      json_data['user_translation_id_list'].each do |id|
        translation_ids.push(id)
      end
    end
    return translation_ids.uniq
  end

end
