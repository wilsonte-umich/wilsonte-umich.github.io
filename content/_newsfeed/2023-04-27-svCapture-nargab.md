---
date: 2023-04-27
title: Wilson et al. 2023
subtitle: "svCapture paper accepted"
description: "svCapture paper accepted in NAR Genomics and Bioinformatics"
event_type: publication # primary type of the event, used to create the small, colored post callout
banner_image_source: project=CNV_Mechanisms # the item whose banner image will be adopted by this event
badges: 
  - project=CNV_Mechanisms
  - project=MDI
  - person=Samreen_Ahmed
  - publication=Wilson_2022
  - funding=CA200731
---

Our paper on the technical development of **svCapture** - 
a novel approach to error correction and suppression in next generation
sequencing optimized for detecting very rare structural variant junctions - 
has been accepted for publication in 
[NAR Genomics and Bioinformatics](https://academic.oup.com/nargab).

The paper is currently available in 
[preprint form](https://www.biorxiv.org/content/10.1101/2022.07.07.497948v1) 
on bioRxiv.

The approach builds on the concepts of 
[Duplex Sequencing](https://pubmed.ncbi.nlm.nih.gov/22853953/), developed at 
[TwinStrand Biosciences](https://twinstrandbio.com/), 
our collaborator on the project.

Success of the method depends on a carefully constructed 
data analysis pipeline made available as part of our
[SVX tool suite](https://github.com/wilsontelab/svx-mdi-tools)
through the
[Michigan Data Interface](https://midataint.github.io/docs/overview/) (MDI).

Perhaps most importantly, the methods in the paper underlie
a series of studies that comprise a manuscript in preparation
regarding the cell cycle timing of structural variant formation.

{% include figure.html  
    image="assets/images/publications/cnv/svCapture-APH-deletions.png"
    title="Detecting aphidicolin-induced deletions by svCapture."
    caption="Demonstration of the clear induction of structural variants above a low background signal, after error suppression and correction by svCapture."
%}
