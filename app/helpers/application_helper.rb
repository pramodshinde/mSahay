module ApplicationHelper

  def status_klass(status)
    case status
    when 'open'
      'badge badge-primary'
    when 'closed'
      'badge badge-success'
    when 'pending'
      'badge badge-warning'
    when 'solved'
      'badge badge-success'
    when 'hold'
      'badge badge-danger'
    when 'new'
      'badge badge-info'
    end
  end

  def flash_class(m_type)
    case m_type
      when 'notice' then "success"
      when 'alert' then "danger"
      else 'warning'
    end
  end
end
