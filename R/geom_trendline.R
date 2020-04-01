#' Add Trendline to 'ggplot'
#'
#' An extension of 'ggplot2' for add trendline to ggplot,
#' by using different models built in the 'geom_trendline()' function. The function includes the following models in the latest version:
#' "line2P" (formula as: y=a*x+b), "line3P" (y=a*x^2+b*x+c), "log2P" (y=a*ln(x)+b), "exp3P" (y=a*exp(b*x)+c), and "power3P" (y=a*x^b+c).
#'
#' @param x,y  the x and y arguments provide the x and y coordinates for the plot. Any reasonable way of defining the coordinates is acceptable.
#' @param model select which model to fit. Default is "line2P". The "model" should be one of c("line2P", "line3P", "log2P", "exp3P", "power3P"), their formulas are as follows:\cr "line2P": y=a*x+b \cr "line3P": y=a*x^2+b*x+c \cr "log2P": y=a*ln(x)+b \cr "exp3P": y=a*exp(b*x)+c \cr "power3P": y=a*x^b+c
#' @param ... additional parameters to \code{\link[ggplot2]{geom_line}},such as color, linetype, size, alpha.

#' @import graphics
#' @import stats
#' @import ggplot2
#' @export
#' @details The values of each parameter of regression model can be found by typing \code{\link[basicTrendline]{trendline}} fuction in this pacakge.\cr\cr The linear models (line2P, line3P, log2P) in this package are estimated by \code{\link[stats]{lm}} function, while the nonlinear models (exp3P, power3P) are estimated by \code{\link[stats]{nls}} function (i.e., least-squares method).
#' @examples
#' library(ggplot2)
#' library(basicTrendline2)
#' x <- 1:5
#' y <- c(2,14,18,19,20)
#' xy <- data.frame(x, y)
#'
#' gg <- ggplot(aes(x,y), data = xy) + geom_point()
#' gg + geom_trendline(model = "line2P")
#' gg + geom_trendline(model = "log2P", color = "blue")
#' gg + geom_trendline(model = "exp3P", color="red", linetype="dashed", size = 10, alpha = 0.3)
#'
#' @author Weiping Mei, Guangchuang Yu
#' @seealso  \code{\link{trendline2}}, \code{\link{SSexp3P}}, \code{\link{SSpower3P}}, \code{\link[stats]{nls}}, \code{\link[stats]{selfStart}}

geom_trendline <- function(mapping=NULL, data=NULL, model="line2P", ...)
{
  model=model
  if (is.null(mapping))
    mapping <- aes_(x=~x, y=~y)

  OK <- complete.cases(x, y)
  x <- x[OK]
  y <- y[OK]
  z<-data.frame(x,y)

  xx<-seq(min(x),max(x),len=100)

  if (is.null(data))
    data <- z

# 1) model="line2P"
if (model== c("line2P"))
  {
  formula = 'y = a*x + b'

  fit<- lm(y~x)

  yfit<-predict(fit,data.frame(x=xx))   # definite x using xx

  if (requireNamespace("ggplot2", quietly = TRUE)){
     gg1 <- ggplot2::geom_line(mapping=aes(xx,yfit), data=data.frame(xx,yfit), ...)
    }
 }

# 2) model="line3P"
  if (model== c("line3P"))
  {
    formula = 'y = a*x^2 + b*x + c'

    fit<-lm(y~I(x^2)+x)

    xx.square=xx^2

    yfit<-predict(fit,data.frame(x=xx,x.square=xx.square))   # definite x using xx

    if (requireNamespace("ggplot2", quietly = TRUE)){
      gg1 <- ggplot2::geom_line(mapping=aes(xx,yfit), data=data.frame(xx,yfit), ...)
    }
  }

# 3) model="log2P"
if (model== c("log2P"))
  {
  formula = 'y = a*ln(x) + b'

  yadj<-y-min(y) #adjust

  if (min(x)>0)
  {


    fit<-lm(yadj~log(x))  # adjusted y used

    yfit<-predict(fit,data.frame(x=xx))   # definite x using xx

    yfit<-yfit+min(y)  # re-adjust

    if (requireNamespace("ggplot2", quietly = TRUE)){
      gg1 <- ggplot2::geom_line(mapping=aes(xx,yfit), data=data.frame(xx,yfit), ...)
    }

   }else{
    stop("
'log2P' model need ALL x values greater than 0. Try other models.")
  }
  }

# 4) model="exp3P"
  if (model== c("exp3P"))
  {
    formula = 'y = a*exp(b*x) + c'

    yadj<-y-min(y)+1
    zzz<-data.frame(x,yadj)

    n=length(x)
    k = 3     # k means the count numbers of parameters(i.e., 'a', 'b' and 'c' in this case)

# use selfStart function 'SSexp3P' for y = a *exp(b*x)+ c
# fit model
    fit<-nls(yadj~SSexp3P(x,a,b,c),data=zzz) # use 'yadj', in case of extreme high y-values with low range, such as y= c(600002,600014,600018,600019,600020).

    yfit<-predict(fit,data.frame(x=xx))   # definite x using xx

    yfit=yfit+min(y)-1

    if (requireNamespace("ggplot2", quietly = TRUE)){
      gg1 <- ggplot2::geom_line(mapping=aes(xx,yfit), data=data.frame(xx,yfit), ...)
      }
  }

 # 5) model="power3P"
if (model== c("power3P"))
    {
    formula = 'y = a*x^b + c'

    yadj<-y-min(y)+1
    zzz<-data.frame(x,yadj)

    n<-length(x)
    k =  3  # k means the count numbers of parameters (i.e., a, b and c in this case)

    if (min(x)>0){

      fit<-nls(yadj~SSpower3P(x,a,b,c),data=zzz)  # use 'yadj', in case of extreme high y-values with low range.

      yfit<-predict(fit,data.frame(x=xx))   # definite x using xx

      yfit=yfit+min(y)-1

      if (requireNamespace("ggplot2", quietly = TRUE)){
        gg1 <- ggplot2::geom_line(mapping=aes(xx,yfit), data=data.frame(xx,yfit), ...)
        }
    }else{
    stop("
'power3P' model need ALL x values greater than 0. Try other models.")
  }

# 6) beyond the  built-in models.

}else{
  Check<-c("line2P","line3P","log2P","exp3P","power3P")
  if (!model %in% Check)
  stop("
\"model\" should be one of c(\"lin2P\",\"line3P\",\"log2P\",\"exp3P\",\"power3P\".")
}

gg1  # geom_trendline
}
