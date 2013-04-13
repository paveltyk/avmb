ActionView::Base.field_error_proc = Proc.new{ |html_tag, _| html_tag }
