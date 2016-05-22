class LanguageController < ApiController

  def list
    languages = Language.all
    render(json: languages)
  end

  def show
    language = Language.find_by(id: params[:id])
    if !language
      render :json => {:error => 'not-found'}.to_json, :status => 500
    else
      render(json: language)
    end
  end

  def create
    language = Language.create(name: params[:name])
    if !language
      render :json => {:error => 'internal-server-error'}.to_json, :status => 500
    else
      render(json: language)
    end
  end

  def destroy
    language = Language.find_by(id: params[:id])
    if !language
      render :json => {:error => 'not-found'}.to_json, :status => 500
    else
      language.destroy
      language = Language.find_by(id: params[:id])
      if !language
        render :json => {:status => 'ok'}.to_json, :status => 200
      else
        render :json => {:error => 'internal-server-error'}.to_json, :status => 500
      end
    end
  end

  def update
    language = Language.find_by(id: params[:id])
    if !language
      render :json => {:error => 'not-found'}.to_json, :status => 500
    else
      language.name = params[:name]
      if language.save
        render(json: language)
      else
        render :json => {:error => 'internal-server-error'}.to_json, :status => 500
      end
    end
  end


end
