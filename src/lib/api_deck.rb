
class APIDeck < Syro::Deck

  HTTPCodes = {
    NOT_FOUND: 404, UNAUTHORIZED: 401, BAD_REQUEST: 400, UNPROCESSABLE: 422
  }

  def response_with(data, status: :OK)
    response_data = { status: status, data: data }
    json response_data
  end


end
