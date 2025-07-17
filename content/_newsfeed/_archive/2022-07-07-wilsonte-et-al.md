---
date: '2022-07-07'
title: Wilson et al. 2022
subtitle: svCapture preprint reports new MDI tool suite for structural variant finding
description: svCapture preprint reports new MDI tool suite for structural variant
  finding
event_type: publication
banner_image_source: project=CNV_Mechanisms
badges:
- event=ICEM_2022
- funding=CA200731
- person=Samreen_Ahmed
- project=CNV_Mechanisms
- project=MDI
- publication=Wilson_2023
---

We are thrilled to report our work on the technical development of **svCapture**,
a novel approach to error correction and suppression in next generation
sequencing optimized for detecting very rare structural variant junctions.

The approach builds on the concepts of 
[Duplex Sequencing](https://pubmed.ncbi.nlm.nih.gov/22853953/), developed at 
[TwinStrand Biosciences](https://twinstrandbio.com/), 
our collaborator on the project.

Success of the method depends on a carefully constructed 
data analysis pipeline made available as part of our
[SVX tool suite](https://github.com/wilsontelab/svx-mdi-tools)
through the
[Michigan Data Interface](https://midataint.github.io/docs/overview/) (MDI).

Stay tuned for the journal submission of this work and its companion
biological study, where we will use svCapture to explore the 
timing and mechanisms of chromosomal rearrangement formation at chromosome fragile sites.

{% include figure.html  
    image="assets/images/publications/cnv/svCapture-APH-deletions.png"
    title="Detecting aphidicolin-induced deletions by svCapture."
    caption="Demonstration of the clear induction of structural variants above a low background signal, after error suppression and correction by svCapture."
%}

