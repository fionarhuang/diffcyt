% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/testDS_limma.R
\name{testDS_limma}
\alias{testDS_limma}
\title{Test for differential states: method 'diffcyt-DS-limma'}
\usage{
testDS_limma(d_counts, d_medians, design, contrast, block_id = NULL,
  trend = TRUE, weights = TRUE, markers_to_test = NULL,
  min_cells = 3, min_samples = NULL, plot = TRUE, path = ".")
}
\arguments{
\item{d_counts}{\code{\link{SummarizedExperiment}} object containing cluster cell
counts, from \code{\link{calcCounts}}.}

\item{d_medians}{\code{\link{SummarizedExperiment}} object containing cluster medians
(median marker expression for each cluster-sample combination), from
\code{\link{calcMedians}}. Assumed to contain a logical vector
\code{id_state_markers} in the meta-data (accessed with
\code{metadata(d_medians)$id_state_markers}), which identifies the set of 'cell
state' markers in the list of \code{assays}.}

\item{design}{Design matrix, created with \code{\link{createDesignMatrix}}. See
\code{\link{createDesignMatrix}} for details.}

\item{contrast}{Contrast matrix, created with \code{\link{createContrast}}. See
\code{\link{createContrast}} for details.}

\item{block_id}{(Optional) Vector or factor of block IDs (e.g. patient IDs) for paired
experimental designs, to be included as random effects. If provided, the block IDs
will be included as random effects using the \code{limma}
\code{\link{duplicateCorrelation}} methodology. Alternatively, block IDs can be
included as fixed effects in the design matrix (\code{\link{createDesignMatrix}}).
See details.}

\item{trend}{(Optional) Whether to fit a mean-variance trend when calculating moderated
tests with function \code{\link{eBayes}} from \code{limma} package. When \code{trend
= TRUE}, this is known as the \code{limma-trend} method (Law et al., 2014; Phipson et
al., 2016). Default = TRUE.}

\item{weights}{(Optional) Whether to use cluster cell counts as precision weights
(across all samples and clusters); this allows the \code{limma} model fitting
functions to account for uncertainty due to the total number of cells per sample
(library sizes) and total number of cells per cluster. Default = TRUE.}

\item{markers_to_test}{(Optional) Logical vector specifying which markers to test for
differential expression (from the set of markers stored in the \code{assays} of
\code{d_medians}). Default = all 'cell state' markers, which are identified by the
logical vector \code{id_state_markers} stored in the meta-data of \code{d_medians}.}

\item{min_cells}{Filtering parameter. Default = 3. Clusters are kept for differential
testing if they have at least \code{min_cells} cells in at least \code{min_samples}
samples.}

\item{min_samples}{Filtering parameter. Default = \code{number of samples / 2}, which
is appropriate for two-group comparisons (of equal size). Clusters are kept for
differential testing if they have at least \code{min_cells} cells in at least
\code{min_samples} samples.}

\item{plot}{Whether to save diagnostic plot. Default = TRUE.}

\item{path}{Path for diagnostic plot. Default = current working directory.}
}
\value{
Returns a new \code{\link{SummarizedExperiment}} object, where rows =
  cluster-marker combinations, and columns = samples. In the rows, clusters are
  repeated for each cell state marker (i.e. the sheets or \code{assays} from the
  previous \code{d_medians} object are stacked into a single matrix). Differential test
  results are stored in the \code{rowData} slot. Results include raw p-values
  (\code{p_val}) and adjusted p-values (\code{p_adj}) from the \code{limma} moderated
  tests, which can be used to rank cluster-marker combinations by evidence for
  differential states within cell populations. Additional output columns from the
  \code{limma} tests are also included. The results can be accessed with the
  \code{\link{rowData}} accessor function.
}
\description{
Calculate tests for differential states within cell populations using method
'diffcyt-DS-limma'
}
\details{
Calculates tests for differential states within cell populations (i.e. differential
expression of cell state markers within clusters). Clusters are defined using cell type
markers, and cell states are characterized by the median transformed expression of cell
state markers.

This method uses the \code{\link{limma}} package (Ritchie et al. 2015, \emph{Nucleic
Acids Research}) to fit models and calculate moderated tests at the cluster level.
Moderated tests improve statistical power by sharing information on variability (i.e.
variance across samples for a single cluster) between clusters. By default, we provide
option \code{trend = TRUE} to the \code{limma} \code{\link{eBayes}} function; this fits
a mean-variance trend when calculating moderated tests, which is also known as the
\code{limma-trend} method (Law et al., 2014; Phipson et al., 2016). Diagnostic plots
are shown if \code{plot = TRUE}.

The experimental design must be specified using a design matrix, which can be created
with \code{\link{createDesignMatrix}}. Flexible experimental designs are possible,
including blocking (e.g. paired designs), batch effects, and continuous covariates. See
\code{\link{createDesignMatrix}} for more details.

For paired designs, either fixed effects or random effects can be used. Fixed effects
are simpler, but random effects may improve power in data sets with unbalanced designs
or very large numbers of samples. To use fixed effects, provide the block IDs (e.g.
patient IDs) to \code{\link{createDesignMatrix}}. To use random effects, provide the
\code{block_id} argument here instead. This will make use of the \code{limma}
\code{\link{duplicateCorrelation}} methodology. Note that >2 measures per sample are
not possible in this case (fixed effects should be used instead). Block IDs should not
be included in the design matrix if the \code{limma} \code{duplicateCorrelation}
methodology is used.

The contrast matrix specifying the contrast of interest can be created with
\code{\link{createContrast}}. See \code{\link{createContrast}} for more details.

By default, differential tests are performed for all cell state markers (which are
identified with the vector \code{id_state_markers} stored in the meta-data of the
cluster medians input object). The optional argument \code{markers_to_test} allows the
user to specify a different set of markers to test (e.g. to investigate differences for
cell type markers).

Filtering: Clusters are kept for differential testing if they have at least
\code{min_cells} cells in at least \code{min_samples} samples. This removes clusters
with very low cell counts across conditions, to improve power.

Weights: By default, cluster cell counts are used as precision weights (across all
samples and clusters); allowing the \code{limma} model fitting functions to account for
uncertainty due to the total number of cells per sample (library sizes) and total
number of cells per cluster. This option can also be disabled with \code{weights =
FALSE}, if required.
}
\examples{
# For a complete workflow example demonstrating each step in the 'diffcyt' pipeline, 
# see the package vignette.

# Function to create random data (one sample)
d_random <- function(n = 20000, mean = 0, sd = 1, ncol = 20, cofactor = 5) {
  d <- sinh(matrix(rnorm(n, mean, sd), ncol = ncol)) * cofactor
  colnames(d) <- paste0("marker", sprintf("\%02d", 1:ncol))
  d
}

# Create random data (without differential signal)
set.seed(123)
d_input <- list(
  sample1 = d_random(), 
  sample2 = d_random(), 
  sample3 = d_random(), 
  sample4 = d_random()
)

# Add differential states (DS) signal
ix_DS <- 901:1000
ix_cols_type <- 1:10
ix_cols_DS <- 19:20
d_input[[1]][ix_DS, ix_cols_type] <- d_random(n = 1000, mean = 3, ncol = 10)
d_input[[2]][ix_DS, ix_cols_type] <- d_random(n = 1000, mean = 3, ncol = 10)
d_input[[3]][ix_DS, c(ix_cols_type, ix_cols_DS)] <- d_random(n = 1200, mean = 3, ncol = 12)
d_input[[4]][ix_DS, c(ix_cols_type, ix_cols_DS)] <- d_random(n = 1200, mean = 3, ncol = 12)

experiment_info <- data.frame(
  sample_id = factor(paste0("sample", 1:4)), 
  group_id = factor(c("group1", "group1", "group2", "group2")), 
  stringsAsFactors = FALSE
)

marker_info <- data.frame(
  channel_name = paste0("channel", sprintf("\%03d", 1:20)), 
  marker_name = paste0("marker", sprintf("\%02d", 1:20)), 
  marker_class = factor(c(rep("type", 10), rep("state", 10)), 
                        levels = c("type", "state", "none")), 
  stringsAsFactors = FALSE
)

# Prepare data
d_se <- prepareData(d_input, experiment_info, marker_info)

# Transform data
d_se <- transformData(d_se)

# Generate clusters
d_se <- generateClusters(d_se)

# Calculate counts
d_counts <- calcCounts(d_se)

# Calculate medians
d_medians <- calcMedians(d_se)

# Create design matrix
design <- createDesignMatrix(experiment_info, cols_design = "group_id")

# Create contrast matrix
contrast <- createContrast(c(0, 1))

# Test for differential states (DS) within clusters
res_DS <- testDS_limma(d_counts, d_medians, design, contrast, plot = FALSE)

}
