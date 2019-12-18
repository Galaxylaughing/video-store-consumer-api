class MoviesController < ApplicationController
  # before_action :require_movie, only: [:show]

  def index
    if params[:query]
      data = MovieWrapper.search(params[:query])
    else
      data = Movie.all
    end

    render status: :ok, json: data
  end

  def show
    @movie = Movie.find_by(title: params[:title])
    puts @movie
    if @movie
      render(
        status: :ok,
        json: @movie.as_json(
          only: [:title, :overview, :release_date, :inventory],
          )
        )
    else
      external_movie = MovieWrapper.search(params[:title])
      if external_movie.empty? 
        render status: :not_found, json: { errors: { title: ["No movie with title #{params["title"]}"] } }
      else
        render(
          status: :ok,
          json: external_movie.as_json(
            only: [:title, :overview, :release_date]
            )
          )
      end
    end
  end

  def create 
    @movie = Movie.new(movie_params)
    @movie.inventory = 1
    movie = Movie.find_by(title: params[:title]) 
    if movie == nil && @movie.save
      render(
        status: :ok,
        json: @movie.as_json(
          only: [:title, :overview, :release_date]
          )
        )
    else 
      render(
        status: :bad_request,
        json: @movie.errors.messages.as_json()
        )
    end
  end

  private

  def require_movie
    @movie = Movie.find_by(title: params[:title])
    unless @movie
      render status: :not_found, json: { errors: { title: ["No movie with title #{params["title"]}"] } }
    end
  end

  def movie_params
    params.permit(:title, :overview, :release_date, :inventory, :image_url)
  end
end
