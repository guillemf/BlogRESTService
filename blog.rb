require 'sinatra'
require 'sinatra/json'
require 'sinatra/namespace'
require 'json'

set :port, 9000

namespace '/api/v1' do

    before do
        content_type 'application/json'
    end

    # List posts
    get '/posts' do
        posts = load_posts
        posts.to_json
    end

    post '/posts' do
        requestBody = request.body.read
        if !valid_json?(requestBody)
            halt 400, json({ "Error": "Bad formated request" })
        end

        new_post = JSON.parse(requestBody)
        posts = load_posts

        if find_post(posts, new_post["date"]) != nil
            halt 409, json({ "Error": "There is a post in that date" })
        end

        posts.push(new_post)
        save_posts(posts)
    end

    get '/posts/:date' do |date|
        posts = load_posts
        post = find_post(posts, date)

        if post == nil
            halt 404, json({})
        end

        post.to_json
    end

    put '/posts/:date' do |date|
        posts = load_posts
        post = find_post(posts, date)

        if post == nil
            halt 404, json({})
        end

        posts.delete(post)
        posts.push(new_post)
        save_posts(posts)

        new_post.to_json
    end

    delete '/posts/:date' do |date|
        posts = load_posts
        post = find_post(posts, date)

        if post == nil
            halt 404, json({})
        end

        posts.delete(post)
        save_posts(posts)

        status 204
    end

end

# Aux functions

def load_posts
    file = File.read("posts.json")
    posts = JSON.parse(file)
    return posts
end

def save_posts(post_list)
    File.open("posts.json", "w") do |f|
        f.write(post_list.to_json)
    end
end

def valid_json?(string)
  begin
    !!JSON.parse(string)
  rescue JSON::ParserError
    false
  end
end

def find_post(posts, date)
    posts.each do |aPost|
        if aPost["date"] == date
            return aPost
            break
        end
    end
    return nil
end
