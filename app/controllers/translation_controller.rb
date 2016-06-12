class TranslationController < ApiController


  def list_user
    fullTranslation = []
    uTranslations = current_user.user_translations
    uTranslations.each do |uTranslation|
      t = uTranslation.translation
      elOriginal = TextElement.find_by(id: t.original_id)
      elTranslation = TextElement.find_by(id: t.translated_one_id)
#      uContextTexts = current_user.context_texts.pluck(:id)
      contextTexts = []
      if params[:context_text_id]
        trContextText = TranslationInContextText.where(translation_id: t.id).where(user_id: current_user.id).where(context_text_id: params[:context_text_id])
        contextTexts = [{'context_text_id' => trContextText.context_text_id,
                         'position' => trContextText.position,
                         'selection_length' => trContextText.selection_length}]
      else
        trContextText = TranslationInContextText.where(translation_id: t.id).where(user_id: current_user.id)
        trContextText.each do |tr|
          contextTexts.push('context_text_id' => tr.context_text_id,
                            'position' => tr.position,
                            'selection_length' => tr.selection_length)
        end
      end
      fullTranslation.push('lang_from_id' => elOriginal.language_id,
                           'lang_to_id' => elTranslation.language_id,
                           'original' => elOriginal.value,
                           'translated_one' => elTranslation.value,
                           'part_of_speech' => elOriginal.part_of_speech,
                           'learning_stage' => uTranslation.learning_stage,
                           'next_training_at' => uTranslation.next_training_at,
                           'training_history' => uTranslation.training_history,
                           'context_texts' => contextTexts)
    end
    render(json: fullTranslation)
  end

  def add
    lOriginal = Language.find_by(id: params[:lang_from_id])
    lTranslation = Language.find_by(id: params[:lang_to_id])
    if lOriginal && lTranslation
      ct = ContextText.find_by(id: params[:context_text_id])
      if ct
        elOriginal = TextElement.find_or_create_by(value: params[:original],
                                                   language_id: lOriginal.id, part_of_speech: params[:part_of_speech])
        elTranslation = TextElement.find_or_create_by(value: params[:translated_one],
                                                      language_id: lTranslation.id, part_of_speech: params[:part_of_speech])
        if elOriginal && elTranslation
          t = Translation.find_or_create_by(original_id: elOriginal.id, translated_one_id: elTranslation.id)
          if t
            tContextText = TranslationInContextText.find_or_create_by(position: params[:position],
                                                                      selection_length: params[:selection_length],
                                                                      translation_id: t.id,
                                                                      context_text_id: params[:context_text_id],
                                                                      user_id: current_user.id)
            if tContextText
              d = Date.today
              uTranslation = current_user.user_translations.find_or_create_by(translation: t)
              uTranslation.update_attributes(learning_stage: '1', next_training_at: (d+1).to_s,
                                             training_history: [{when: d.to_s, next_stage: '1'}].to_s)
              if uTranslation
                render :json => {:result => {'text_element_from_id' => elOriginal.id,
                                             'text_element_to_id' => elTranslation.id}}, :status => 200
              else
                render :json => {:error => 'internal-server-error'}, :status => 500
              end
            else
              render :json => {:error => 'internal-server-error'}, :status => 500
            end
          else
            render :json => {:error => 'internal-server-error'}, :status => 500
          end
        else
          render :json => {:error => 'internal-server-error'}, :status => 500
        end
      else
        render :json => {:error => 'context text is not found'}, :status => 500
      end
    else
      render :json => {:error => 'language is not found'}, :status => 500
    end

  end

end
