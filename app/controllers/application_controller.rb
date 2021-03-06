# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :title
  def index
    fetch
    countries_dropdown
    @gclid = gclid
    session[:country] ||= Geocoder.search(request.remote_ip)
    @location = if params[:location].present?
                  params[:location]
                elsif !@deals.where(country_code: session[:country_code]).empty?
                  session[:country_code]
                else
                  'US'
                end
    if params[:category].present?
      record = @categories.find_by(slug: params[:category])
      @category = record if record.present?
      @deals = @deals.where("category LIKE '#{@category.slug}'")
    end
    @deals = @deals.paginate(page: params[:page], per_page: 20).order('RANDOM()')
    # show deals in random order
    @deals.shuffle
    limit_page_numbers
  end

  def categories
    fetch
    countries_dropdown
   end

  # keep the visible page numbers to a limit so they don't overlap
  # on smaller screens
  def limit_page_numbers
    WillPaginate::ViewHelpers.pagination_options[:inner_window] = 0
    WillPaginate::ViewHelpers.pagination_options[:outer_window] = 0
  end

  private

  def fetch
    fetch_deals
    fetch_categories
  end

  def fetch_deals
    @deals = Deal.all
  end

  def fetch_categories
    @categories = Category.all
  end

  def countries_dropdown
    @countries_dropdown = @deals.map do |d|
      [d.country_code, d.country_code]
    end
    @countries_dropdown.uniq!
  end

  def gclid
    params[:gclid].present? ? "&customid=#{params[:gclid]}" : ''
  end

  def title
    @title = 'Hotdealsfinda'
  end
end
