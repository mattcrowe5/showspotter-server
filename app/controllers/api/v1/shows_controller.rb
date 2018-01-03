require 'time'
class Api::V1::ShowsController < ApplicationController

  def show
    # iterating through decoded to get to the access token and passing it into the header

    @concerts = []
    params['related_artists'].each do |artist|
      artist_hash = RestClient.get("https://api.songkick.com/api/3.0/search/artists.json?apikey=#{ENV["SONG_KEY"]}&query=#{artist['name']}")
      related_artists_params = JSON.parse(artist_hash.body)
      id = related_artists_params['resultsPage']['results']['artist'][0]["id"]
      shows_hash = RestClient.get("https://api.songkick.com/api/3.0/artists/#{id}/calendar.json?apikey=#{ENV["SONG_KEY"]}")
      shows = JSON.parse(shows_hash)["resultsPage"]['results']['event']
      if shows != nil
        filtered_shows = shows.map do |show|
          if show['venue']['metroArea']['displayName'] === params['city']
            binding.pry
            {concert: show["displayName"], venue: show['venue']['displayName'], date: Time.parse(show["start"]["date"]).strftime("%m/%d/%y"), time: Time.parse(show["start"]["time"]).strftime("%l %P"), link: show['uri'], artist: show['performance'][0]['displayName'], photo: artist['photo']}
          end
        end
        @concerts.concat(filtered_shows.compact)
      end

    end


    # making the fetch request to the spotify api and parsing it
    render json: {shows: @concerts}
    # rendering to the back end so the front end can take in the data
  end

  private
  def key
    'KlRpsINW9b1UY6dy'
  end
end
