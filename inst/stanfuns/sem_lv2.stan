  real sem_lv2_lpdf(matrix x, real[,,] alpha, real[,,] B, real[,,] psi, real[,,] gamma, int gamind, real[,] meanx, int[] g, int k, int N, int Ng, int diagpsi, int fullbeta, int nlv, int[] lvind, int nlvno0){
    real ldetcomp[Ng];
    matrix[k,k] iden;
    vector[k] alpha2[Ng];
    vector[k] psivecinv[Ng];
    matrix[k,k] psimatinv[Ng];
    matrix[k,k] psimat[Ng];
    matrix[k,k] siginv[Ng];
    vector[k] xvec;
    vector[k] evlv[Ng];
    int tmpobs[k];
    real xvectm;
    real ldetsum;
    int nov;

    nov = k - nlv;

    iden = diag_matrix(rep_vector(1.0, k));

    if(nlvno0 > 0){
      tmpobs[1:nlvno0] = lvind;
    }
    if(nov > 0){
      for(j in 1:nov){
        tmpobs[nlvno0+j] = nlvno0 + j;
      }
    }

    for(j in 1:Ng){
      alpha2[j] = to_vector(alpha[,1,j]);
    }

    evlv = sem_mean2(alpha2, B, gamma, g, k, Ng, gamind, meanx);


    if(diagpsi){
      for(j in 1:Ng){
        for(i in 1:(nlvno0+nov)){
          psivecinv[j,tmpobs[i]] = 1/psi[tmpobs[i],tmpobs[i],j];
        }
        psimatinv[j] = diag_matrix(psivecinv[j]);

        siginv[j,1:(nlvno0+nov),1:(nlvno0+nov)] = (iden[tmpobs[1:(nlvno0+nov)],tmpobs[1:(nlvno0+nov)]] - to_matrix(B[tmpobs[1:(nlvno0+nov)],tmpobs[1:(nlvno0+nov)],j])') * psimatinv[j,tmpobs[1:(nlvno0+nov)],tmpobs[1:(nlvno0+nov)]] * (iden[tmpobs[1:(nlvno0+nov)],tmpobs[1:(nlvno0+nov)]] - to_matrix(B[tmpobs[1:(nlvno0+nov)],tmpobs[1:(nlvno0+nov)],j]));

	if(fullbeta){
	  ldetcomp[j] = log_determinant(iden[tmpobs[1:(nlvno0+nov)],tmpobs[1:(nlvno0+nov)]] - to_matrix(B[tmpobs[1:(nlvno0+nov)],tmpobs[1:(nlvno0+nov)],j]));
	  ldetcomp[j] = ldetcomp[j] + ldetcomp[j] + sum(log(diagonal(to_matrix(psi[tmpobs[1:(nlvno0+nov)],tmpobs[1:(nlvno0+nov)],j]))));
	} else {
          ldetcomp[j] = sum(log(diagonal(to_matrix(psi[tmpobs[1:(nlvno0+nov)],tmpobs[1:(nlvno0+nov)],j]))));
  	}
      }
    } else {
      for(j in 1:Ng){
	psimat[j] = to_matrix(psi[,,j]) + to_matrix(psi[,,j])' - diag_matrix(diagonal(to_matrix(psi[,,j])));

	ldetcomp[j] = log_determinant(psimat[j,tmpobs[1:(nlvno0+nov)],tmpobs[1:(nlvno0+nov)]]);
	if(fullbeta){
	  ldetcomp[j] = ldetcomp[j] + 2 * log_determinant(iden[tmpobs[1:(nlvno0+nov)],tmpobs[1:(nlvno0+nov)]] - to_matrix(B[tmpobs[1:(nlvno0+nov)],tmpobs[1:(nlvno0+nov)],j]));
	}

	psimatinv[j] = psimat[j];
	psimatinv[j,1:(nlvno0+nov),1:(nlvno0+nov)] = inverse_spd(psimat[j,tmpobs[1:(nlvno0+nov)],tmpobs[1:(nlvno0+nov)]]);
        siginv[j,1:(nlvno0+nov),1:(nlvno0+nov)] = (iden[tmpobs[1:(nlvno0+nov)],tmpobs[1:(nlvno0+nov)]] - to_matrix(B[tmpobs[1:(nlvno0+nov)],tmpobs[1:(nlvno0+nov)],j])') * psimatinv[j,1:(nlvno0+nov),1:(nlvno0+nov)] * (iden[tmpobs[1:(nlvno0+nov)],tmpobs[1:(nlvno0+nov)]] - to_matrix(B[tmpobs[1:(nlvno0+nov)],tmpobs[1:(nlvno0+nov)],j]));
      }
    }

    xvectm = 0;
    ldetsum = 0;
    for(i in 1:N){
      xvec = x[i,]';
      xvectm = xvectm + (xvec[tmpobs[1:(nlvno0+nov)]] - evlv[g[i],tmpobs[1:(nlvno0+nov)]])' * siginv[g[i],1:(nlvno0+nov),1:(nlvno0+nov)] * (xvec[tmpobs[1:(nlvno0+nov)]] - evlv[g[i],tmpobs[1:(nlvno0+nov)]]);
      ldetsum = ldetsum + ldetcomp[g[i]];
    }

    return -0.5 * (ldetsum + xvectm);
  }