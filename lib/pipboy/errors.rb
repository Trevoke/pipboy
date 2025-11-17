module Pipboy
  class FileDoesNotExist < StandardError
  end

  class FileNotWatched < StandardError
  end

  class FileExistsError < StandardError
  end
end
