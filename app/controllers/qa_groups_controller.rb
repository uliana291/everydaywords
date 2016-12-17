class QaGroupsController < ApplicationController

  def list
    qa_groups = QaGroup.all
    render(json: qa_groups)
  end

end
