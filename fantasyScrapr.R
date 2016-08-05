###scrape injury data
library(stringr)
library(XML)


#base url
baseUrl <- 'http://www.foxsports.com/nfl/injuries?season=2015&seasonType=1&'

#urls are simple - just change number for week of season
urls <- paste(baseUrl, 'week=',1:16 , sep='')

#loop to scrape and clean injury data from every week
finalDF <- data.frame(stringsAsFactors=FALSE)
for(i in 1:length(urls)){
  x <- readHTMLTable(urls[i], as.data.frame=TRUE, stringsAsFactors=FALSE)
  
  df <- data.frame(stringsAsFactors=FALSE)
  for(j in 1:length(x)){
    df <- rbind(df, x[[j]])
  }
  
  df$Position <- str_sub(df$Player, start = -2)
  df$Position <- gsub("[\t]", "", df$Position)
  
  df$Player <- gsub('(.*?)\r.*', '\\1', df$Player)
  
  df$Week <- i
  
  finalDF <- rbind(finalDF, df)
  
  print(i/length(urls)*100)
}

#scrape players and points (only those who played are included)
weeks <- 1:16
positions <- c('QB','RB','WR','TE','K')
statsDF <- data.frame(stringsAsFactors=FALSE)
for(i in 1:length(weeks)){
  for(j in 1:length(positions)){
    print(paste(weeks[i], positions[j]))
    url <- paste('http://www.footballdb.com/fantasy-football/index.html?pos=', positions[j], '&yr=2015&wk=',i,'&rules=1',sep='')
    
    x <- readHTMLTable(url, as.data.frame=TRUE, stringsAsFactors=FALSE)
    df <- x[[1]]
    
    df$Team <- str_to_upper(gsub('.*?,.*?, (.*)', '\\1', df$Player))
    df$Player <- gsub('(.*?),.*','\\1', df$Player)
    
    df <- subset(df, select=c('Player', 'Pts*', 'Team'))
    
    df$week <- i
    
    statsDF <- rbind(statsDF, df)
  }
}


#limit to only those positions which we care about (coded in positions variable already)
injured <- finalDF[finalDF$Position %in% positions,]

#fix name format to match other databases
lastName <- gsub('(^.*?),.*', '\\1', injured$Player)
firstName <- gsub('.*, (.*)', '\\1', injured$Player)

injured$nameConvert <- paste(firstName, lastName)

#figure out who played
injured$played <- NA
for(i in 1:nrow(injured)){
  weekStats <- statsDF[statsDF$week == injured$Week[i],]
  
  if(injured$nameConvert[i] %in% weekStats$Player == TRUE) {
    injured$played[i] <- 'yes'
  } else {
    injured$played[i] <- 'no'
  }
}

#assign teams
for(i in 1:nrow(injured)){
  injured$Team[i] <- statsDF$Team[which(injured$nameConvert[i] == statsDF$Player)][1]
}





