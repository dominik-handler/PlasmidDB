class PlasmidsController < ApplicationController

  before_filter :authenticate_author!

  def index
    @plasmids = Plasmid.all.sort_by(&:internal_id).reverse

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @plasmids }
    end
  end

  def show
    @plasmid = Plasmid.find(params[:id])

    ## init 3 attachment slots
    (3 - @plasmid.attachments.count).times { @plasmid.attachments.build }

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
    pars = params
    pars = wrap_params(pars) if params[:pk] == "editable"

    respond_to do |format|
      if @plasmid.update_attributes(pars[:plasmid])
        format.html { redirect_to @plasmid, notice: 'Plasmid was successfully updated.' }
        format.json { render :json => @plasmid, :status => :ok }
      else
        error_string = "Unknown error."
        error_string = @plasmid.errors.messages.map { |k,v|
          "#{k}: #{v.first}"
        }.join("; ") unless @plasmid.errors.empty?

        format.html {
          redirect_to plasmid_path(@plasmid),
          flash: {
            error: "Plasmid could not be saved successfully: #{error_string}"
          }
        }

        format.json { render json: @plasmid.errors, status: :unprocessable_entity }
      end
    end
  end

  def wrap_params(params)
    pars = {}
    pars[:plasmid] = { params["name"] => params ["value"] }
    return pars
  end

  def filter_index
    filter = params[:filter]
    results = []

    if filter == "*"
      results = Plasmid.all.sort.reverse
    else
      solr_search = Plasmid.search do
        fulltext filter
        paginate :per_page => 9999
      end

      results = solr_search.results.sort.reverse
    end

    hits = Hash.new
    results.each_with_index { |r,i|
      hits[i] = Hash.new
      hits[i]["id"] = r.id
      hits[i]["internal_id"] = r.internal_id
      hits[i]["plasmid_name"] = r.name.html_safe
      hits[i]["gene_insert"] = r.info.fetch("gene_insert") { "n/a" }
      hits[i]["author"] = r.author.username
      hits[i]["time_added"] = r.updated_at.strftime("%d/%m/%Y")
    }

    render :json => hits
  end


  def destroy
    @plasmid = Plasmid.find(params[:id])
    @plasmid.destroy

    respond_to do |format|
      format.html { redirect_to plasmids_path, alert: 'Plasmid was successfully removed.' }
      format.json { head :no_content }
    end
  end

  def remove_image
    @plasmid = Plasmid.find(params[:plasmid_id])
    @plasmid.plasmid_map.destroy
    @plasmid.save

    respond_to do |format|
      format.html { redirect_to plasmid_path(@plasmid), alert: 'Plasmid map was successfully removed.' }
      format.json { head :no_content }
    end
  end

  def remove_attachment
    @plasmid = Plasmid.find(params[:plasmid_id])
    @attachment = @plasmid.attachments.find(params[:attachment])
    @attachment.destroy
    @plasmid.save

    respond_to do |format|
      format.html { redirect_to plasmid_path(@plasmid), alert: 'Plasmid attachment was successfully removed.' }
      format.json { head :no_content }
    end
  end
end
