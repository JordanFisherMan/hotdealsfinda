# frozen_string_literal: true

class ResultsController < ApplicationController
  include ApplicationHelper

  def results
    fetch
    countries_dropdown
    affiliate_id
    gclid
    @search = {
      present: params[:search].present? && params[:search] != '',
      title: 'Search',
      query: params[:search] || ''
    }
    @category = {
      present: params[:category].present?,
      title: 'Category',
      query: category_query
    }
    @sort = {
      present: params[:sort].present?,
      title: 'Sort',
      query: params[:sort] || ''
    }
    @location = if params[:location].present?
                  params[:location]
                elsif !@deals.where(country_code: session[:country_code]).empty?
                  session[:country_code]
                else
                  'US'
                end

    query = []
    query.push("country_code LIKE '#{@location}'")
    if @search[:present] && @search[:query] == 'xbox one'
      query.push("(title ILIKE '%xbox one%' AND title ILIKE '%console%' OR highlights ILIKE '%xbox one%')")
    elsif @search[:present]
      query.push("(title ILIKE '%#{@search[:query]}%' OR highlights ILIKE '%#{@search[:query]}%')")
    end
    if params[:category].present? && @category[:query] != 'all'
      query.push("category LIKE '#{params[:category]}'")
    end
    @results = @deals.where(query.join(' AND '))
    limit_page_numbers
    @results = if params[:sort].present? && params[:sort] == 'price'
                 @results.order(sort_price: :asc)
               else
                 @results.order(rating: :desc)
            end
    # for the recommended deals in the sidebar
    @recommended_deals = if @results.count > 4
                           @results.order('RANDOM()').limit(4)
                         else
                           @deals.order('RANDOM()').limit(4)
    end
    # paginate deals
    @results = @results.paginate(page: params[:page], per_page: 20)
    @related_searches = if @search[:present] && @search[:query] == 'xbox one'
       ['xbox live', 'xbox one x', 'xbox one controller', 'xbox live gold', 'crackdown 3', 'zoo tycoon', 'halo reach', 'xbox gift card', 'elite controller']
    else
      %w[Teeth Car Paint Cheap Beauty Luxury Nails Massage Spa]
    end

    @current_filters = []
    @current_filters.push(@search) if @search[:present]
    @current_filters.push(@category) if @category[:present]

    # target page title
    if @search[:present] && @search[:query] == 'xbox one'
      @title = "Xbox One Deals"
    end
  end

  private

  def category_query
    if params[:category].present?
      tidy_string(params[:category])
    else
      ''
    end
  end
end
