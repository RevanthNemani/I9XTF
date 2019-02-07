library(digest)

user_base <- data.frame(
  user = c("Revanth","HI9","IT","IS","Audit"),
  password = sapply(c("master@2019","9IHonly@2019","infotec2019","infosec2019","audit2019"), digest, "sha512"), 
  permissions = c("master","standard","standard","audit","audit"),
  name = c("Revanth Nemani","IFRS 9 Head","Information Technology","Head Information Security","Auditor"),
  stringsAsFactors = FALSE,row.names = NULL
)
saveRDS(user_base, "data/users/user_base.rds")
