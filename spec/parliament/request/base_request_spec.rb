require_relative '../../spec_helper'

describe Parliament::Request::BaseRequest, vcr: true do
  context 'with endpoint set via an initializer' do
    before :each do
      Parliament::Request::BaseRequest.base_url = 'http://test.com'
    end

    it 'allows you to get the API endpoint within an instance' do
      expect(Parliament::Request::BaseRequest.new.base_url).to eq('http://test.com')
    end

    it 'allows you to get the API endpoint on the class' do
      expect(Parliament::Request::BaseRequest.base_url).to eq('http://test.com')
    end

    it 'allows you to override the API endpoint via the initializer' do
      expect(Parliament::Request::BaseRequest.new(base_url: 'http://example.com').base_url).to eq('http://example.com')
    end
  end

  context 'with endpoint set by initializer' do
    it 'allows you to pass an endpoint within an initializer call' do
      expect(Parliament::Request::BaseRequest.new(base_url: 'http://test.com').base_url).to eq('http://test.com')
    end
  end

  describe '#get' do
    context 'it returns a status code of 200' do
      let(:base_response) { Parliament::Request::BaseRequest.new(base_url: 'http://localhost:3030/parties/current').get }

      it 'returns a Parliament::Response::BaseResponse' do
        expect(base_response).to be_a(Parliament::Response::BaseResponse)
      end

      it 'raises a Parliament::NoContentError if there is no content' do
        expect {
          Parliament::Request::BaseRequest.new(base_url: 'http://localhost:3030/parties/lookup/mnisId/abc').get
        }.to raise_error(Parliament::NoContentResponseError, '200 HTTP status code received from: http://localhost:3030/parties/lookup/mnisId/abc - OK')
      end

      it 'raises a Parliament::NoContentError if there is no content and has been gzip compressed' do
        expect {
          Parliament::Request::BaseRequest.new(base_url: 'http://localhost:3030/parties/lookup/mnisId/abc').get
        }.to raise_error(Parliament::NoContentResponseError, '200 HTTP status code received from: http://localhost:3030/parties/lookup/mnisId/abc - OK')
      end
    end

    context 'it returns a status code in either the 400 or 500 range' do
      it 'and raises client error when status is within the 400 range' do
        stub_request(:get, 'http://localhost:3030/dogs/cats').to_return(status: 404)

        expect {
          Parliament::Request::BaseRequest.new(base_url: 'http://localhost:3030/dogs/cats').get
        }.to raise_error(Parliament::ClientError, '404 HTTP status code received from: http://localhost:3030/dogs/cats - ')
      end

      it 'and raises server error when status is within the 500 range' do
        stub_request(:get, 'http://localhost:3030/parties/current').to_return(status: 500)

        expect {
          Parliament::Request::BaseRequest.new(base_url: 'http://localhost:3030/parties/current').get
        }.to raise_error(Parliament::ServerError, '500 HTTP status code received from: http://localhost:3030/parties/current - ')
      end
    end

    context 'it accepts query parameters' do
      it 'sets the query parameters correctly when passed in' do
        Parliament::Request::BaseRequest.new(base_url: 'http://localhost:3030/people/lookup').get(params: { source: 'mnisId', id: '3898' })

        expect(WebMock).to have_requested(:get, 'http://localhost:3030/people/lookup?id=3898&source=mnisId').
            with(:headers => {'Accept'=>['*/*', 'application/n-triples'], 'User-Agent'=>'Ruby'}).once
      end

      it 'merges passed in params with @query_params' do
        request = Parliament::Request::BaseRequest.new(base_url: 'http://localhost:3030/people/lookup')
        request.instance_variable_set(:@query_params, { test: true })
        request.get(params: { source: 'mnisId', id: '3898' })

        expect(WebMock).to have_requested(:get, 'http://localhost:3030/people/lookup?test=true&id=3898&source=mnisId').
            with(:headers => {'Accept'=>['*/*', 'application/n-triples'], 'User-Agent'=>'Ruby'}).once
      end
    end

    context 'it accepts headers' do
      it 'sets the header correctly when passed in' do
        Parliament::Request::BaseRequest.headers = { 'Access-Token'=>'Test-Token' }
        Parliament::Request::BaseRequest.new(base_url: 'http://localhost:3030/people').get

        expect(WebMock).to have_requested(:get, 'http://localhost:3030/people').
            with(:headers => {'Accept'=>['*/*', 'application/n-triples'], 'Access-Token'=>'Test-Token', 'User-Agent'=>'Ruby'}).once
      end

      it 'sets the default headers only when no additional headers passed' do
        Parliament::Request::BaseRequest.new(base_url: 'http://localhost:3030/people').get

        expect(WebMock).to have_requested(:get, 'http://localhost:3030/people').
            with(:headers => {'Accept'=>['*/*', 'application/n-triples'], 'User-Agent'=>'Ruby'}).once
      end
    end
  end

  describe '#post' do
    context 'it returns a status code of 200' do
      let(:base_response) { Parliament::Request::BaseRequest.new(base_url: 'http://localhost:3030/parties/current').post }

      it 'returns a Parliament::Response::BaseResponse' do
        stub_request(:post, 'http://localhost:3030/parties/current').to_return(status: 200, body: '{}', headers: { 'Content-Length' => 30 })

        expect(base_response).to be_a(Parliament::Response::BaseResponse)
      end

      it 'raises a Parliament::NoContentError if there is no content' do
        stub_request(:post, 'http://localhost:3030/parties/lookup/mnisId/abc').to_return(status: [200, 'OK'], headers: { 'Content-Length' => 0 })

        expect {
          Parliament::Request::BaseRequest.new(base_url: 'http://localhost:3030/parties/lookup/mnisId/abc').post
        }.to raise_error(Parliament::NoContentResponseError, '200 HTTP status code received from: http://localhost:3030/parties/lookup/mnisId/abc - OK')
      end

      it 'raises a Parliament::NoContentError if there is no content and has been gzip compressed' do
        stub_request(:post, 'http://localhost:3030/parties/lookup/mnisId/abc').to_return(status: [200, 'OK'], body: '')

        expect {
          Parliament::Request::BaseRequest.new(base_url: 'http://localhost:3030/parties/lookup/mnisId/abc').post
        }.to raise_error(Parliament::NoContentResponseError, '200 HTTP status code received from: http://localhost:3030/parties/lookup/mnisId/abc - OK')
      end
    end

    context 'it returns a status code in either the 400 or 500 range' do
      it 'and raises client error when status is within the 400 range' do
        stub_request(:post, 'http://localhost:3030/dogs/cats').to_return(status: 404)

        expect {
          Parliament::Request::BaseRequest.new(base_url: 'http://localhost:3030/dogs/cats').post
        }.to raise_error(Parliament::ClientError, '404 HTTP status code received from: http://localhost:3030/dogs/cats - ')
      end

      it 'and raises server error when status is within the 500 range' do
        stub_request(:post, 'http://localhost:3030/parties/current').to_return(status: 500)

        expect {
          Parliament::Request::BaseRequest.new(base_url: 'http://localhost:3030/parties/current').post
        }.to raise_error(Parliament::ServerError, '500 HTTP status code received from: http://localhost:3030/parties/current - ')
      end
    end

    context 'it accepts query parameters' do
      it 'sets the query parameters correctly when passed in' do
        stub_request(:post, 'http://localhost:3030/people/lookup?id=3898&source=mnisId').to_return(status: 200, headers: { 'Content-Length' => 30 })

        Parliament::Request::BaseRequest.new(base_url: 'http://localhost:3030/people/lookup').post(params: { source: 'mnisId', id: '3898' })

        expect(WebMock).to have_requested(:post, 'http://localhost:3030/people/lookup?id=3898&source=mnisId').
            with(:headers => {'Accept'=>['*/*', 'application/n-triples'], 'User-Agent'=>'Ruby'}).once
      end

      it 'merges passed in params with @query_params' do
        stub_request(:post, 'http://localhost:3030/people/lookup?test=true&id=3898&source=mnisId').to_return(status: 200, headers: { 'Content-Length' => 30 })

        request = Parliament::Request::BaseRequest.new(base_url: 'http://localhost:3030/people/lookup')
        request.instance_variable_set(:@query_params, { test: true })
        request.post(params: { source: 'mnisId', id: '3898' })

        expect(WebMock).to have_requested(:post, 'http://localhost:3030/people/lookup?test=true&id=3898&source=mnisId').
            with(:headers => {'Accept'=>['*/*', 'application/n-triples'], 'User-Agent'=>'Ruby'}).once
      end
    end

    context 'it accepts headers' do
      before :each do
        stub_request(:post, 'http://localhost:3030/people').to_return(status: 200, headers: { 'Content-Length' => 30 })
      end

      it 'sets the header correctly when passed in' do
        Parliament::Request::BaseRequest.headers = { 'Access-Token'=>'Test-Token' }
        Parliament::Request::BaseRequest.new(base_url: 'http://localhost:3030/people').post

        expect(WebMock).to have_requested(:post, 'http://localhost:3030/people').
            with(:headers => {'Accept'=>['*/*', 'application/n-triples'], 'Access-Token'=>'Test-Token', 'User-Agent'=>'Ruby'}).once
      end

      it 'sets the default headers only when no additional headers passed' do
        Parliament::Request::BaseRequest.new(base_url: 'http://localhost:3030/people').post

        expect(WebMock).to have_requested(:post, 'http://localhost:3030/people').
            with(:headers => {'Accept'=>['*/*', 'application/n-triples'], 'User-Agent'=>'Ruby'}).once
      end
    end

    context 'it accepts a body' do
      before :each do
        stub_request(:post, 'http://localhost:3030/people').to_return(status: 200, headers: { 'Content-Length' => 30 })
      end

      it 'sends the body as passed' do
        Parliament::Request::BaseRequest.new(base_url: 'http://localhost:3030/people').post(body: { foo: 'bar', test: true, number: 1 }.to_json)

        expect(WebMock).to have_requested(:post, 'http://localhost:3030/people').
            with(:body => '{"foo":"bar","test":true,"number":1}').once
      end
    end

    context 'it accepts a timeout' do
      before :each do
        stub_request(:post, 'http://localhost:3030/people').to_return(status: 200, body: '{}')
      end

      it 'still processes our request' do
        Parliament::Request::BaseRequest.new(base_url: 'http://localhost:3030/people').post(body: { foo: 'bar', test: true, number: 1 }.to_json, timeout: 1)

        expect(WebMock).to have_requested(:post, 'http://localhost:3030/people').
            with(:body => '{"foo":"bar","test":true,"number":1}').once
      end
    end
  end
end
