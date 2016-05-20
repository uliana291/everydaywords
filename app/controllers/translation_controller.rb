class TranslationController < ApiController


  def list_user
    fullTranslation = []
    uTranslations = current_user.translations
    uTranslations.each do |uT|
      t = Translation.find_by(id: uT.translation_id).first
      elOriginal = TextElement.find_by(id: t.original_id).first
      elTranslation = TextElement.find_by(id: t.translated_one_id).first
      uContextTexts = current_user.context_texts.pluck(:context_text_id)
      trContextText = TranslationInContextText.find_by(translationd_id: t.id).where(context_text_id: uContextTexts)
      trContextText.each do |tr|
        fullTranslation << ['lang_from_id' => elOriginal.language_id,
                           'lang_to_id' => elTranslation.language_id,
                           'original' => elOriginal.value,
                           'translated_one' => elTranslation.value,
                           'part_of_speech' => elOriginal.part_of_speech,
                           'context_text_id' => tr.context_text_id,
                           'position' => tr.position,
                           'selection_length' => tr.selection_length]
      end
    end
    render(json: fullTranslation)
  end

  def add
    lOriginal = Language.find_by(id: params[:lang_from_id])
    lTranslation = Language.find_by(id: params[:lang_to_id])
    if lOriginal && lTranslation
      ct = ContextText.find_by(id: params[:context_text_id])
      if ct
        elOriginal = TextElement.create(value: params[:original],
                                        language_id: lOriginal.id, part_of_speech: params[:part_of_speech])
        elTranslation = TextElement.create(value: params[:translated_one],
                                           language_id: lTranslation.id, part_of_speech: params[:part_of_speech])
        if elOriginal && elTranslation
          t = Translation.create(original_id: elOriginal.id, translated_one_id: elTranslation.id)
          if t
            tContextText = TranslationInContextText.create(position: params[:position],
                                                           selection_length: params[:selection_length],
                                                           translation_id: t.id,
                                                           context_text_id: params[:context_text_id])
            if tContextText
              current_user.translations<<t
              render :json => {:result => { 'text_element_from_id' => elOriginal.id,
                                            'text_element_to_id' => elTranslation.id } }.to_json, :status => 200
            else
              render :json => {:error => 'internal-server-error'}.to_json, :status => 500
            end
          else
            render :json => {:error => 'internal-server-error'}.to_json, :status => 500
          end
        else
          render :json => {:error => 'internal-server-error'}.to_json, :status => 500
        end
      else
        render :json => {:error => 'context text is not found'}.to_json, :status => 404
      end
    else
      render :json => {:error => 'language is not found'}.to_json, :status => 404
    end

  end

end
