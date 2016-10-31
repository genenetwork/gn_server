defmodule GnServer.Router.Biodalliance.SNP do

  alias GnServer.Biodalliance.SNPDensity

  use Maru.Router
  plug CORSPlug, headers: ["Range", "If-None-Match", "Accept-Ranges"], expose: ["Content-Range"]

  namespace :snp do
    namespace :features do
      route_param :chr, type: String do
        params do
          optional :start,      type: Float
          optional :end,        type: Float
        end

        get do
          start_mb = params[:start] / 1000000
          end_mb = params[:end] / 1000000
          bins = 350
          step_mb = (end_mb - start_mb) / bins

          counts = SNPDensity.snp_counts(params[:chr], start_mb, end_mb, step_mb, 2, 3)
          |> SNPDensity.counts_mb_to_b
          json(conn, %{features: counts})
        end
      end
    end
  end
end
