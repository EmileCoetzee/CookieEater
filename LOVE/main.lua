function love.load()
    --image assets
    cookieEaterImage = love.graphics.newImage("assets/cookieEaterHead2.png")
    cookieEaterImage:setFilter("nearest", "nearest")
    cookiePocketImage = love.graphics.newImage("assets/cookiePocket.png")
    cookiePocketImage:setFilter("nearest", "nearest")
    cookieImage = love.graphics.newImage("assets/cookiee.png")
    cookieImage:setFilter("nearest", "nearest")
    math.randomseed(os.time()) --seed random generator as Lua's RNG is deterministic
    cookie = generateCookie()
    cookieEater = {
        {
        image = cookieEaterImage,
        x = 0,
        y = 0,
        height = 30,
        width = 30
        },
    }
    cookieEaterPositionHistory = {}
    direction = "right"
    speed = 0
    acceleration = 15
    gameOver = false
    score = 0
    positionHistory = {}
    prevXPoint = 0 
    prevYPoint = 0
end

function createRect()
    local lastRect = cookieEater[#cookieEater]
    rect = {}
    image = cookiePocketImage
    rect.x = lastRect.x
    rect.y = lastRect.y
    rect.height = 18
    rect.width = 18

    table.insert(cookieEater, rect)
end

function detectWallCollision(x, y)
    if ((x > love.graphics.getWidth() - 30) or x < 0 or y > (love.graphics.getHeight() - 30) or y < 0) then
        return true
    end

    return false
end

function detectEat(cookieEaterHead)
    local width = cookieEaterHead.width
    local height = cookieEaterHead.height
    local x = cookieEaterHead.x
    local y = cookieEaterHead.y

    if (x < cookie.x + cookie.image:getWidth()
        and cookie.x < x + width
        and y < cookie.y + cookie.image:getHeight()
        and cookie.y < y + height
        ) 
        then
        return true
    end

    return false
end

function generateCookie()
    return {
        image = cookieImage,
        x = math.random(0, love.graphics.getWidth() - 30),
        y = math.random(0, love.graphics.getHeight() - 30)
    }
end

function detectSelfCollision(cookieEater)
    local head = cookieEater[1]
    
    for i = 5, #cookieEater do
        local cookiePocket = cookieEater[i]

        if (head.x < cookiePocket.x + cookiePocket.width
        and cookiePocket.x < head.x + head.width
        and head.y < cookiePocket.y + cookiePocket.height
        and cookiePocket.y < head.y + head.height
        ) 
        then 
            print(head.width, cookiePocket.width)
            print(head.x, head.y, cookiePocket.x, cookiePocket.y)
            return true
        end
    end
    return false
end

function love.update(dt)

    --check for out of bounds of screen
    if (detectWallCollision(cookieEater[1].x, cookieEater[1].y)) then 
        gameOver = true
        return
    end

    --check for cookie eater head and cookie collision
    if (detectEat(cookieEater[1])) then
        score = score + 1
        cookie = generateCookie()
        createRect()
    end

    --check for cookie eater self-collision
    if (detectSelfCollision(cookieEater)) then
        gameOver = true
        return
    end

    for i = 2, #cookieEater do
        local position = cookieEaterPositionHistory[i - 1]

        if (position) then
            cookieEater[i].x = position.x
            cookieEater[i].y = position.y
        end
    end

    speed = speed + acceleration * dt
    score = score + 0.02

    --set movement in the correct direction
    if (direction == "right") then
       cookieEater[1].x = cookieEater[1].x + speed * dt
    end

    if (direction == "down") then
        cookieEater[1].y = cookieEater[1].y + speed * dt
    end

    if (direction == "left") then
        cookieEater[1].x = cookieEater[1].x - speed * dt
    end

    if (direction == "up") then
        cookieEater[1].y = cookieEater[1].y - speed * dt
    end


    --create history of this point when the head has moved 15 pixels
    local distanceX = cookieEater[1].x - prevXPoint
    local distanceY = cookieEater[1].y - prevYPoint
    local distanceBetweenPoints = math.sqrt(distanceX*distanceX + distanceY*distanceY)

    if distanceBetweenPoints >= 15 then
        table.insert(cookieEaterPositionHistory, 1, {x = cookieEater[1].x, y = cookieEater[1].y})

        prevXPoint = cookieEater[1].x
        prevYPoint = cookieEater[1].y
    end

 if #cookieEaterPositionHistory > #cookieEater * 15 then
        table.remove(cookieEaterPositionHistory)
    end


   
end

--listen for arrow presses
function love.keypressed(key)
    if key == "up" then
        direction = "up"
    end
    if key == "down" then
        direction = "down"
    end
    if key == "left" then
        direction = "left"
    end
    if key == "right" then
        direction = "right"
    end
end


function love.draw()
   
    love.graphics.setColor(1,1,1,1) --ensures that image has no tinting
    love.graphics.draw(cookie.image, cookie.x, cookie.y)

    love.graphics.setColor(255, 255, 255)
    for i = #cookieEater, 2, -1 do
        love.graphics.draw(cookiePocketImage, cookieEater[i].x, cookieEater[i].y)
    end

    love.graphics.setColor(1,1,1,1) --ensures that image has no tinting
    love.graphics.draw(cookieEater[1].image, cookieEater[1].x, cookieEater[1].y)

    if (gameOver == true) then
        love.graphics.setNewFont(20)
        love.graphics.setColor(255,0,0)
        love.graphics.printf("Game Over...", 0, love.graphics.getHeight()/2 - 10, love.graphics.getWidth(), "center")

        love.graphics.setNewFont(28)
        love.graphics.setColor(255,255,255)

        love.graphics.printf("Score: " .. math.floor(score), 0, love.graphics.getHeight()/2 + 40, love.graphics.getWidth(), "center")
    end
end


