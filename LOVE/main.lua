function love.load()
    --image assets
    cookieEaterImage = love.graphics.newImage("assets/cookieEaterHead.png")
    cookieEaterImage:setFilter("nearest", "nearest")
    cookiePocketImage = love.graphics.newImage("assets/cookiePocket.png")
    cookiePocketImage:setFilter("nearest", "nearest")
    cookieImage = love.graphics.newImage("assets/cookie.png")
    cookieImage:setFilter("nearest", "nearest")
    cookieImageScaleX = 50 / cookieImage:getWidth()
    cookieImageScaleY = 50 / cookieImage:getHeight()
    listOfRectangles = {
        {
        image = cookieEaterImage,
        x = 0,
        y = 0,
        height = 30,
        width = 30
        },
    }
    rectPositionHistory = {}
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
    local lastRect = listOfRectangles[#listOfRectangles]
    rect = {}
    image = cookiePocketImage
    rect.x = lastRect.x
    rect.y = lastRect.y
    rect.height = 18
    rect.width = 18

    table.insert(listOfRectangles, rect)
end

function love.update(dt)
    --check for out of bounds of screen
    if ((listOfRectangles[1].x > love.graphics.getWidth() - 30) or listOfRectangles[1].x < 0 or listOfRectangles[1].y > (love.graphics.getHeight() - 30) or listOfRectangles[1].y < 0) then
        gameOver = true
        return
    end


    for i = 2, #listOfRectangles do
        local position = rectPositionHistory[i - 1]

        if (position) then
            listOfRectangles[i].x = position.x
            listOfRectangles[i].y = position.y
        end
    end

    speed = speed + acceleration * dt
    score = score + 0.02

    --set movement in the correct direction
    if (direction == "right") then
       listOfRectangles[1].x = listOfRectangles[1].x + speed * dt
    end

    if (direction == "down") then
        listOfRectangles[1].y = listOfRectangles[1].y + speed * dt
    end

    if (direction == "left") then
        listOfRectangles[1].x = listOfRectangles[1].x - speed * dt
    end

    if (direction == "up") then
        listOfRectangles[1].y = listOfRectangles[1].y - speed * dt
    end


    --create history of this point when the head has moved 15 pixels
    local distanceX = listOfRectangles[1].x - prevXPoint
    local distancyY = listOfRectangles[1].y - prevYPoint
    local distanceBetweenPoints = math.sqrt(distanceX*distanceX + distancyY*distancyY)

    if distanceBetweenPoints >= 15 then
        table.insert(rectPositionHistory, 1, {x = listOfRectangles[1].x, y = listOfRectangles[1].y})

        prevXPoint = listOfRectangles[1].x
        prevYPoint = listOfRectangles[1].y
    end

 if #rectPositionHistory > #listOfRectangles * 15 then
        table.remove(rectPositionHistory)
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

    if key == "space" then
        createRect()
    end
end


function love.draw()
   
    love.graphics.setColor(1,1,1,1) --ensures that image has no tinting
    love.graphics.draw(cookieImage, 10, 10, 0, cookieImageScaleX, cookieImageScaleY)

    love.graphics.setColor(255, 255, 255)
    for i = #listOfRectangles, 2, -1 do
        love.graphics.draw(cookiePocketImage, listOfRectangles[i].x, listOfRectangles[i].y)
    end

    love.graphics.setColor(1,1,1,1) --ensures that image has no tinting
    love.graphics.draw(listOfRectangles[1].image, listOfRectangles[1].x, listOfRectangles[1].y)

    if (gameOver == true) then
        love.graphics.setNewFont(20)
        love.graphics.setColor(255,0,0)
        love.graphics.printf("Game Over...", 0, love.graphics.getHeight()/2 - 10, love.graphics.getWidth(), "center")

        love.graphics.setNewFont(28)
        love.graphics.setColor(255,255,255)

        love.graphics.printf("Score: " .. math.floor(score), 0, love.graphics.getHeight()/2 + 40, love.graphics.getWidth(), "center")
    end
end


