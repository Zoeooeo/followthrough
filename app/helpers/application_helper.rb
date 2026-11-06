module ApplicationHelper
  # Each status gets its own style: staff reports use a dashed outline,
  # family-confirmed results use a solid one, so they never look alike.
  def status_badge(concern)
    tag.span(concern.status_label, class: "badge badge-#{concern.status.to_s.dasherize}")
  end
end
