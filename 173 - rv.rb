def read_txt(file_name)
  file = File.open(file_name, "rb" )
  data = file.read
  file.close
  return data
end

def write_txt(data, filename)
  if File.file?(filename)
    File.delete(filename)
  end
  f = File.new(filename, "wb")
  f.write(data)
  f.close
end

def read_object(file_name)
  file = File.open(file_name, "rb")
  result = Marshal.load(file)
  file.close
  return result
end

def write_object(obj, file_name, append_flag = false)
  if !append_flag && File.file?(file_name)
    File.delete(file_name)
  end
  list_file = File.open(file_name, "wb")
  Marshal.dump(obj, list_file)
  list_file.close
end

def deleteDir(dir)
  if File.directory?(dir)
    Dir.foreach(dir) do |file|
      if ((file.to_s != ".") and (file.to_s != ".."))
        deleteDir("#{dir}/#{file}")
      end
    end
    Dir.delete(dir)
  else
    File.delete(dir)
  end
end

class Export_rb_record
   attr_reader :size, :sn, :fn
    def initialize(size, sn, fn)
      @size = size
      @sn = sn
      @fn = fn
    end
end

def unpack(script_file_name = "Data/Scripts.rvdata")
  scripts = read_object(script_file_name)
  output_dir = "Scripts"

  if File.directory?(output_dir)
    deleteDir(output_dir)
    Dir.mkdir(output_dir)
  else
    Dir.mkdir(output_dir)
  end

  list = ""
  arr = Array.new
  scripts.each do |a|
    size = a[0]
    sn = a[1]
    fn = output_dir + "/" + sn + ".rb"
    d = 1
    while File.file?(fn)
      fn = output_dir + "/" + sn + "_" + d.to_s + ".rb"
      d = d + 1
    end
    record = Export_rb_record.new(size, sn, fn)
    arr.push(record)
    data = a[2]
    data = Zlib::Inflate.inflate(data)
    if data.size != 0
      write_txt(data, fn)
      list = list + sn + "\n" + fn + "\n"
    else
      list = list + sn + "\n\n"
    end
  end
  write_txt(list, output_dir + "/Scripts.list")
  write_object(arr, output_dir + "/list.rbl")
end

def pack(dump_file_name = "dump.rvdata")
  arr = Array.new
  input_dir = "Scripts"
  list_file_name = input_dir + "/list.rbl"
  empty_data = Zlib::Deflate.deflate("", Zlib::BEST_COMPRESSION)
  if File.file?(list_file_name)
    ary = read_object list_file_name
    ary.each do |f|
      size = f.size
      sn = f.sn
      fn = f.fn
      if File.file?(fn)
        data = read_txt(fn)
        data = Zlib::Deflate.deflate(data, Zlib::BEST_COMPRESSION)
      else
        data = empty_data
      end
      scr = [data.size, sn, data]
      arr.push(scr)
    end
  else
    return
  end
  write_object(arr, dump_file_name)
  #deleteDir(input_dir)

end

ini = Ini_File.new("Game.ini")
build_option = ini.get_profile("Build","Option").to_i
build_source = ini.get_profile("Build", "Source")
build_target = ini.get_profile("Build", "Target")
if build_option != 0
  if build_option == 1 or build_option == 3
    if build_source == nil
      build_source = "Data/Scripts.rvdata"
    end
    unpack build_source
    print "unpack from " + build_source + " done "
  end
  if build_option == 2 or build_option == 3
    if build_target == nil
      build_target = "dump.rvdata"
    end
    pack build_target
    print "pack to " + build_target + " done"
  end
  exit
end
