# Exposes _bibliography/papers.bib as site.data["papers"], so templates outside
# jekyll-scholar's {% bibliography %} tag can loop over the publications. Used by
# the Schema.org ScholarlyArticle list in _includes/metadata.html and by
# /llms.txt and /llms-full.txt. The bib file stays the single source of truth.
require "bibtex"

module Jekyll
  class BibDataGenerator < Generator
    safe true
    priority :highest

    def generate(site)
      scholar = site.config["scholar"] || {}
      path = File.join(site.source, scholar["source"] || "_bibliography", scholar["bibliography"] || "papers.bib")
      return unless File.exist?(path)

      bib = BibTeX.open(path, filter: :latex)
      papers = bib.entries.values.map { |e| Jekyll::BibData.entry_hash(e) }
      # Stable sort: newest year first, bib-file order within a year.
      site.data["papers"] = papers.each_with_index.sort_by { |p, i| [-p["year"].to_i, i] }.map(&:first)
    end
  end

  module BibData
    module_function

    def clean(value)
      return nil if value.nil?
      value.to_s.gsub(/[{}]/, "").gsub(/\s+/, " ").strip
    end

    def canonical_url(fields)
      journal = fields["journal"].to_s
      if fields["url"] then fields["url"]
      elsif fields["doi"] then "https://doi.org/#{fields['doi']}"
      elsif fields["arxiv"] then "https://arxiv.org/abs/#{fields['arxiv']}"
      elsif fields["ssrn"] then "https://papers.ssrn.com/sol3/papers.cfm?abstract_id=#{fields['ssrn']}"
      elsif journal.include?("arXiv:") then "https://arxiv.org/abs/#{journal.split('arXiv:').last.strip}"
      end
    end

    def entry_hash(e)
      fields = {}
      e.fields.each { |name, value| fields[name.to_s] = clean(value) }
      authors = e[:author] ? e[:author].map { |n| clean([n.first, n.last].compact.join(" ")) } : []
      {
        "key" => e.key.to_s,
        "type" => e.type.to_s,
        "title" => fields["title"],
        "authors" => authors,
        "venue" => fields["journal"] || fields["booktitle"],
        "year" => fields["year"],
        "doi" => fields["doi"],
        "url" => canonical_url(fields),
        "abstract" => fields["abstract"],
        "code" => fields["code"],
        "status" => fields["keywords"].to_s.include?("working-paper") ? "working-paper" : "published",
        "selected" => fields["selected"] == "true",
      }
    end
  end
end
