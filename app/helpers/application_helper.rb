module ApplicationHelper
  def tidy_string(string)
    split = string.split('-')
    split.join(' ')
  end

  def url_friendly(string)
    split = string.downcase.split(' ')
    split.join('-')
  end

  def asset_exists?(path)
    if defined?(Rails.env.production) && Rails.env.production?
      if Rails.configuration.assets.compile
        Rails.application.precompiled_assets.include? path
      else
        Rails.application.assets_manifest.assets[path].present?
      end
    else
      Rails.application.assets.find_asset(path) != nil
    end
  end

  # takes a filter to avoid and sends the params for all of the rest
  def replace_filter(new_filter = nil)
    filters = @current_filters.map{ |filter|
      unless filter[:title] == new_filter
        "&#{filter[:title].downcase}=#{filter[:query]}"
      end
    }
    filters.compact.join
  end

  def remove_filter(remove_filter)
    filters = @current_filters.map{ |filter|
      unless filter[:title] == remove_filter
        "#{filter[:title].downcase}=#{filter[:query]}"
      end
    }
    if filters.compact.join('&') == ""
      return ""
    else
      return filters.compact.join('&')
    end
  end
end
