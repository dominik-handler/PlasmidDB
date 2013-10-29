class PlasmidsController < ApplicationController

  before_filter :authenticate_author!

  def index
    @plasmids = Plasmid.all.sort_by(&:internal_id)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @plasmids }
    end
  end

  def show
    @plasmid = Plasmid.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @plasmid }
    end
  end

  def new
    @plasmid = Plasmid.new
    @plasmid.internal_id = get_next_available_id()

    ## init 3 attachment slots
    3.times { @plasmid.attachments.build }

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @plasmid }
    end
  end

  def get_next_available_id
    last_plasmid = Plasmid.all.sort.last
    value = last_plasmid.nil? ? "JB000" : last_plasmid.internal_id
    return value.next
  end

  def create
    @plasmid = Plasmid.new(params[:plasmid])
    @plasmid.author = current_author
    @plasmid.internal_id = get_next_available_id()

    respond_to do |format|
      if @plasmid.save
        format.html { redirect_to @plasmid, notice: 'Plasmid was successfully created.' }
        format.json { render json: @plasmid, status: :created, location: @plasmid }
      else
        format.html { render action: "new" }
        format.json { render json: @plasmid.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @plasmid = Plasmid.find(params[:id])

    respond_to do |format|
      if @plasmid.update_attributes(params[:plasmid])
        format.html { redirect_to @plasmid, notice: 'Plasmid was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @plasmid.errors, status: :unprocessable_entity }
      end
    end
  end


  def destroy
    @plasmid = Plasmid.find(params[:id])
    @plasmid.destroy

    respond_to do |format|
      format.html { redirect_to plasmids_path, alert: 'Plasmid was successfully removed.' }
      format.json { head :no_content }
    end
  end
end
