class LocationUrlMapsController < ApplicationController
  # GET /location_url_maps
  # GET /location_url_maps.json
  def index
    @location_url_maps = LocationUrlMap.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @location_url_maps }
    end
  end

  # GET /location_url_maps/1
  # GET /location_url_maps/1.json
  def show
    @location_url_map = LocationUrlMap.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @location_url_map }
    end
  end

  # GET /location_url_maps/new
  # GET /location_url_maps/new.json
  def new
    @location_url_map = LocationUrlMap.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @location_url_map }
    end
  end

  # GET /location_url_maps/1/edit
  def edit
    @location_url_map = LocationUrlMap.find(params[:id])
  end

  # POST /location_url_maps
  # POST /location_url_maps.json
  def create
    @location_url_map = LocationUrlMap.new(params[:location_url_map])

    respond_to do |format|
      if @location_url_map.save
        format.html { redirect_to @location_url_map, notice: 'Location url map was successfully created.' }
        format.json { render json: @location_url_map, status: :created, location: @location_url_map }
      else
        format.html { render action: "new" }
        format.json { render json: @location_url_map.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /location_url_maps/1
  # PUT /location_url_maps/1.json
  def update
    @location_url_map = LocationUrlMap.find(params[:id])

    respond_to do |format|
      if @location_url_map.update_attributes(params[:location_url_map])
        format.html { redirect_to @location_url_map, notice: 'Location url map was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @location_url_map.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /location_url_maps/1
  # DELETE /location_url_maps/1.json
  def destroy
    @location_url_map = LocationUrlMap.find(params[:id])
    @location_url_map.destroy

    respond_to do |format|
      format.html { redirect_to location_url_maps_url }
      format.json { head :no_content }
    end
  end
end
