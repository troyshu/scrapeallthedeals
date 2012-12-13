class DealsController < ApplicationController
  # GET /deals
  # GET /deals.json
  def index
    

    if params[:deal_type] and params[:static_location]
      @deals = Deal.where :deal_type=>params[:deal_type], :static_location=>params[:static_location]
    else
      #@deals = Deal.all
      #for now, redirect all index requests to miami/adventure
      params[:deal_type] = "adventure"
      params[:static_location] = "miami"
      @deals = Deal.where :deal_type=>params[:deal_type], :static_location=>params[:static_location]

    end

    @deal_type = params[:deal_type]
    @static_location = params[:static_location]

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @deals }
    end
  end

  # GET /deals/1
  # GET /deals/1.json
  def show
    @deal = Deal.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @deal }
    end
  end

  # GET /deals/new
  # GET /deals/new.json
  def new
    @deal = Deal.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @deal }
    end
  end

  # GET /deals/1/edit
  def edit
    @deal = Deal.find(params[:id])
  end

  # POST /deals
  # POST /deals.json
  def create
    @deal = Deal.new(params[:deal])

    respond_to do |format|
      if @deal.save
        format.html { redirect_to @deal, notice: 'Deal was successfully created.' }
        format.json { render json: @deal, status: :created, location: @deal }
      else
        format.html { render action: "new" }
        format.json { render json: @deal.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /deals/1
  # PUT /deals/1.json
  def update
    @deal = Deal.find(params[:id])

    respond_to do |format|
      if @deal.update_attributes(params[:deal])
        format.html { redirect_to @deal, notice: 'Deal was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @deal.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /deals/1
  # DELETE /deals/1.json
  def destroy
    @deal = Deal.find(params[:id])
    @deal.destroy

    respond_to do |format|
      format.html { redirect_to deals_url }
      format.json { head :no_content }
    end
  end
end
