#! /usr/bin/env ruby
#
# Convert a GN .geno file to R/qtl format. Example
#
# ruby geno2rqtl.rb cross.geno
#
# will write cross_geno.csv, cross_gmap.csv and cross.yaml
#
# you can pass in multiple .geno files

require 'json'

date = '20150722' # still hard-coded

ARGV.each do |fn|
  h = {}
  inds = cols = nil
  print "Parsing #{fn}\n"
  base = File.basename(fn,".geno")
  geno = base + '_geno.csv'
  gmap = base + '_gmap.csv'
  gjson = base + ".json"
  geno_f = File.open(geno,"w")
  gmap_f = File.open(gmap,"w")

  print "Writing #{geno}, #{gmap}...\n"
  count = 0
  File.open(fn).each_line do |l|
    if l =~ /^#/
      # ---- Remark
      next
    elsif l =~ /^@(\S+):(\S+)/
      # ---- Header meta-info
      h[$1] = $2
    elsif l =~ /Chr\tLocus/i
      # ---- Column info
      cols = l.chomp.split(/\t/)
      p cols
      inds = cols[4..-1]
      # p inds
      geno_f.write((["marker"]+inds).join(",")+"\n")
      gmap_f.write("marker,chr,pos,Mb\n")
    else
      # ---- Genotypes
      count += 1
      fields = l.chomp.split(/\t/)
      # p fields
      geno_f.write(fields[1])
      raise "Comma not allowed in marker name" if fields[1] =~ /,/
      geno_f.write(","+fields[4..-1].join(","))
      geno_f.write("\n")

      gmap_f.write([fields[1],fields[0],fields[2],fields[3]].join(",")+"\n")
    end
  end
  p h
  print "Writing #{gjson}...\n"
  # R/qtl supports riself, f2, do...
  crosstype =
    case h["type"]
    when "riset" then "riself"
    else
      h["type"]
    end
  prefix = "#{h["name"]}/"
  h2 = {
    description: h["name"],
    crosstype: crosstype,
    geno: prefix+"geno.csv",
    geno_transposed: true,
    metadata: {
      original: { source: "GeneNetwork" },
      geno: { unique_id: "xxx",
              date: date },
      gmap: { unique_id: "xxx",
              date: date },
    genotypes_descr: {
      1 => "maternal", 2 => :paternal, 3 => :heterozygous
    }},
    genotypes: {
      h["mat"] => 1,
      h["pat"] => 2,
      h["het"] => 3
    },
    "x_chr": "X",
    "na.strings": [h["unk"]],
    gmap: prefix+"gmap.csv"
  }
  # Close files and calculated md5
  gmap_f.close
  geno_f.close
  md5 = `md5sum #{geno}`.split[0]
  md5_m = `md5sum #{gmap}`.split[0]
  h2[:metadata][:geno][:unique_id] = md5
  h2[:metadata][:gmap][:unique_id] = md5_m
  # Now give geno a full name
  md5_geno = `md5sum #{fn}`.split[0]
  h2[:metadata][:original][:unique_id] = md5_geno
  h2[:metadata][:original][:date] = date
  # rename file
  new_geno = base+'_geno_'+md5+'_'+date+'.csv'
  File.rename(geno, new_geno)
  new_gmap = base+'_gmap_'+md5_m+'_'+date+'.csv'
  File.rename(gmap, new_gmap)
  h2[:geno] = prefix+new_geno
  h2[:gmap] = prefix+new_gmap
  # write json
  gjson_f = File.open(gjson,"w")
  gjson_f.print h2.to_json
  File.rename(fn, base+'_'+md5_geno+'_'+date+'.geno')
end
