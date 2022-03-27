module ApplicationHelper
  ASCENDING = "asc".freeze
  DESCENDING = "desc".freeze
  SORTABLE_DIRECTIONS = [ASCENDING, DESCENDING].freeze
  # Unicode arrows.
  UP_ARROW = "&#9650".freeze
  DOWN_ARROW = "&#9660".freeze

  def sortable(column, title=nil)
    title ||= column.titleize

    direction_arrow = ''
    direction = nil
    if column == sort_column
      if sort_direction == ASCENDING
        direction_arrow = UP_ARROW
        direction = DESCENDING
      else
        direction_arrow = DOWN_ARROW
        direction = ASCENDING
      end
    end

    per_page = params[:per_page] if params[:per_page].present?
    header_with_arrow = (direction_arrow + title).html_safe
    return link_to header_with_arrow, { :sort => column, :direction => direction, :per_page => per_page }
  end
end
