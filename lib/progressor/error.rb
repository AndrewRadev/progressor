class Progressor
  # A custom error class for targeted catching. All Progressor errors will be
  # wrapped in a Progressor::Error.
  #
  class Error < RuntimeError
  end
end
