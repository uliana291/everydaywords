class ContextTextController < ApiController

  def list
    context_texts = ContextText.all
    render(json: Oj.dump(context_texts))
  end

  def create
    if Language.find_by(id: params[:language_id])
      context_text = ContextText.create(context_params)
      if !context_text
        render :json => {:error => 'internal-server-error'}.to_json, :status => 500
      else
        render :json => {:result => { 'id' => context_text.id } }.to_json, :status => 200
      end
    else
      render :json => {:error => 'language is not found'}.to_json, :status => 404
    end
  end

  def destroy
    context_text = ContextText.find_by(id: params[:id])
    if !context_text
      render :json => {:error => 'not-found'}.to_json, :status => 404
    else
      context_text.destroy
      context_text = ContextText.find_by(id: params[:id])
      if !context_text
        render :json => {:status => 'ok'}.to_json, :status => 200
      else
        render :json => {:error => 'internal-server-error'}.to_json, :status => 500
      end
    end
  end

  def update
    context_text = ContextText.find_by(id: params[:id])
    if !context_text
      render :json => {:error => 'not-found'}.to_json, :status => 404
    else
      if context_text.update_attributes(context_params)
        render :json => {:status => 'ok'}.to_json, :status => 200
      else
        render :json => {:error => 'internal-server-error'}.to_json, :status => 500
      end
    end
  end

  def show
    context_text = ContextText.find_by(id: params[:id])
    if !context_text
      render :json => {:error => 'not-found'}.to_json, :status => 404
    else
      render(json: Oj.dump(context_text))
    end
  end

  private
  def context_params
    params.permit(:url, :title, :whole_text,
                                 :language_id)
  end

end
