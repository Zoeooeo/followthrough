module ApplicationHelper
  # Staff reports use a dashed outline and family-confirmed results a solid one, so they never look alike.
  def status_badge(concern)
    tag.span(concern.status_label, class: "badge badge-#{concern.status.to_s.dasherize}")
  end

  def role_badge(membership)
    tag.span(membership.role_label, class: "badge badge-role-#{membership.role}")
  end

  def short_date(date)
    date.to_date.strftime("%B %-d, %Y")
  end
end
