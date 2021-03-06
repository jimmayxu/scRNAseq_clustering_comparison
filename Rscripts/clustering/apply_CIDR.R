## Apply CIDR

suppressPackageStartupMessages({
  library(cidr)
})

apply_CIDR <- function(sce, params, k) {
  tryCatch({
    dat <- counts(sce)
    st <- system.time({
      sData <- scDataConstructor(dat, tagType = "raw")
      sData <- determineDropoutCandidates(sData)
      sData <- wThreshold(sData)
      sData <- scDissim(sData, threads = 1)
      sData <- scPCA(sData, plotPC = FALSE)
      sData <- nPC(sData)
      
      ## Cluster with preset number of clusters
      sDataC <- scCluster(object = sData, nCluster = k, 
                          nPC = sData@nPC, cMethod = "ward.D2")
      cluster <- sDataC@clusters
      names(cluster) <- colnames(sDataC@tags)
    })
    ## Determine number of clusters automatically
    sDataA <- scCluster(object = sData, n = max(params$range_clusters),
                        nPC = sData@nPC, cMethod = "ward.D2")
    est_k <- sDataA@nCluster
    
    st <- c(user.self = st[["user.self"]], sys.self = st[["sys.self"]], 
            user.child = st[["user.child"]], sys.child = st[["sys.child"]],
            elapsed = st[["elapsed"]])
    list(st = st, cluster = cluster, est_k = est_k)
  }, error = function(e) {
    list(st = c(user.self = NA, sys.self = NA, user.child = NA, sys.child = NA,
                elapsed = NA), 
         cluster = structure(rep(NA, ncol(sce)), names = colnames(sce)),
         est_k = NA)
  })
}
