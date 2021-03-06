## File Name: tam_ctt_wrapper.R
## File Version: 0.08


tam_ctt_wrapper <- function( resp, wlescore=NULL, group=NULL, allocate=30, progress=TRUE,
    version=3)
{
    I <- ncol(resp)
    resp <- cbind( "_h"="h", resp )
    resp <- as.matrix(resp)
    resp0 <- resp
    maxK <- allocate
    if ( is.null(wlescore) ){
        est_wle <- 0
        wlescore <- rep(1, nrow(resp) )
    } else {
        est_wle <- 1
    }
    wlescore0 <- wlescore
    pvscores <- NULL
    pvscores0 <- pvscores
    # define progress bar
    if ( is.null(group) ){
        group <- rep(1, nrow(resp) )
    }
    groups <- sort( unique( group )    )
    G <- length(groups)
    I <- ncol(resp)
    dfr <- NULL
    for (gg in 1:G){
        ind.gg <- which( group==groups[gg] )
        resp <- resp0[ ind.gg, ]
        wlescore <- wlescore0[ ind.gg ]
        prg <- round( seq( 1, I, len=10 ) )
        prg[ prg==I ] <- I-1
        if (progress){
            cat("|")
            cat( paste( rep("*", 10 ), collapse="") )
            cat("| Group", groups[gg], "\n|")
            prg <- round( seq( 1, I, len=10 ) )
            prg[ prg==I ] <- I-1
        }

        if ( ! progress ){ prg <- 1 }
        resp <- as.matrix( t(resp) )
        if (version==2){
            res <- tam_rcpp_ctt2( TDAT=resp, WLE=wlescore, MAXK=maxK, EST_WLE=est_wle, prg=prg )
        }
        if (version==3){
            res <- tam_rcpp_ctt3( TDAT=resp, WLE=wlescore, MAXK=maxK, EST_WLE=est_wle, prg=prg )
        }
        ind <- which( paste(res$desV) !="" )
        res1 <- res$des[ ind, ]
        dfr.gg <- data.frame( "group"=groups[gg], "groupindex"=gg,
                    "itemno"=res1[,1]-1, "item"=colnames(resp0)[res1[,1]])
        dfr.gg$N <- res1[,2]
        dfr.gg$Categ <- res$desV[ ind ]
        dfr.gg$AbsFreq <- res1[,4]
        dfr.gg$RelFreq <- dfr.gg$AbsFreq / dfr.gg$N
        dfr.gg$rpb.WLE <- res1[,8]
        dfr.gg$M.WLE <- res1[,5]
        dfr.gg$SD.WLE <- res1[,7]
        dfr.gg <- dfr.gg[ ! is.na( dfr.gg$Categ ), ]
        dfr <- rbind( dfr, dfr.gg )
        if (progress){
            cat("|\n")
        }
    } # end group
    dfr <- dfr[ dfr$item !="_h", ]
    dfr$Categ <- gsub( " ", "", dfr$Categ  )
    dfr <- dfr[ order( paste0( 10000+ dfr$itemno, dfr$group, dfr$Categ ) ), ]
    ind <- grep( "WLE", colnames(dfr) )
    if ( est_wle==0 ){ dfr <- dfr[, - ind ] }
    dfr <- data.frame( "index"=seq(1,nrow(dfr) ), dfr )
    return(dfr)
}
#########################################################
