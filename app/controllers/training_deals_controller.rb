class TrainingDealsController < ApplicationController
  # GET /training_deals
  # GET /training_deals.json
  def index
    @training_deals = TrainingDeal.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @training_deals }
    end
  end

  # GET /training_deals/1
  # GET /training_deals/1.json
  def show
    @training_deal = TrainingDeal.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @training_deal }
    end
  end

  # GET /training_deals/new
  # GET /training_deals/new.json
  def new
    @training_deal = TrainingDeal.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @training_deal }
    end
  end

  # GET /training_deals/1/edit
  def edit
    @training_deal = TrainingDeal.find(params[:id])
  end

  # POST /training_deals
  # POST /training_deals.json
  def create
    @training_deal = TrainingDeal.new(params[:training_deal])

    respond_to do |format|
      if @training_deal.save
        format.html { redirect_to @training_deal, notice: 'Training deal was successfully created.' }
        format.json { render json: @training_deal, status: :created, location: @training_deal }
      else
        format.html { render action: "new" }
        format.json { render json: @training_deal.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /training_deals/1
  # PUT /training_deals/1.json
  def update
    @training_deal = TrainingDeal.find(params[:id])

    respond_to do |format|
      if @training_deal.update_attributes(params[:training_deal])
        format.html { redirect_to @training_deal, notice: 'Training deal was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @training_deal.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /training_deals/1
  # DELETE /training_deals/1.json
  def destroy
    @training_deal = TrainingDeal.find(params[:id])
    @training_deal.destroy

    respond_to do |format|
      format.html { redirect_to training_deals_url }
      format.json { head :no_content }
    end
  end
end
