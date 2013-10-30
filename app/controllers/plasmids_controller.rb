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
    pars = parse_params(params)

    respond_to do |format|
      if @plasmid.update_attributes(pars[:plasmid])
        format.html { redirect_to @plasmid, notice: 'Plasmid was successfully updated.' }
        format.json { render :json => @plasmid, :status => :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @plasmid.errors, status: :unprocessable_entity }
      end
    end
  end

  def parse_params(params)
    p = params

    if p["name"] == "info"
      data = @plasmid.info
      data[p["pk"]] = p["value"]

      @plasmid.info = data
      @plasmid.save

      ## take out the hstore related variables from params
      p = p.select { |key, value| ["name", "pk", "value"].include?(key) == false }
    end

    return p
  end

  def filter_index
    filter = params[:filter]

    solr_search = Plasmid.search do
      fulltext filter
      paginate :per_page => 9999
    end

    results = solr_search.results.sort.reverse

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
end
