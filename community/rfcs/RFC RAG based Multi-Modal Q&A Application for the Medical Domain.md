## RFC Title

RAG based Multi-Modal Q&A Application for the Medical Domain

## RFC Content

### Author

[Mustafa Cetin](https://github.com/MSCetin37) 

### Status

Under Review

### Objective
The primary objective of this RFC is to develop a multi-modal QnA application for the medical domain. This application will feature a robust and secure medical data management system designed to enhance developer productivity, simplify data preparation, and effectively integrate multimodal data. Utilizing advanced technologies such as Multi-Modal Vector Database, Retrieval-Augmented Generation (RAG), and Large Multimodal Models (LMMs), the project aims to improve the data security and privacy. Additionally, it seeks to leverage accumulated knowledge in an offline environment and minimize expert involvement in the medical domain, thereby making the system both efficient and user-friendly for medical professionals and researchers. To our knowledge, this use case is not currently covered by the existing OPEA framework. For instance, existing ChatQnA examples primarily focus on text-based queries, and VisualQnA does not utilize RAG or a Multi-Modal Vector Database

### Motivation
In the rapidly evolving medical domain, the ability to quickly and accurately access and analyze data is paramount. However, professionals in this field often face significant challenges due to the complexity of data management, the need for high levels of expertise, and concerns over data security and privacy. These challenges hinder the efficiency of medical research and the delivery of healthcare services.
The development of a Multi-Modal QnA application specifically tailored for the medical domain addresses these critical issues head-on. By building this application we aim to leverage a proven framework to enhance system robustness, privacy and security. The integration of advanced technologies such as Multi-Modal Vector Database, RAG, and LLMs is essential to simplify the data preparation process, enhance the integration of multimodal data, and facilitate the effective use of accumulated knowledge even in offline environments.
This project is motivated by the need to reduce the dependency on extensive expert involvement, which can be a significant bottleneck in the medical field. By automating and streamlining data queries and responses, the Multi-Modal QnA application will empower medical professionals and researchers to make faster, more informed decisions. Furthermore, ensuring the data security and privacy is crucial in maintaining the integrity and confidentiality of sensitive medical information, thus fostering trust and compliance with global data protection regulations (ex: HIPAA, GDPR).
Ultimately, the motivation behind this RFC is to create a Multi-Modal QnA application for the medical domain that not only meets the technical and operational needs of the medical community but also addresses the broader challenges of accessibility, security, and efficiency in medical data management.

### Design Proposal

![image](../../assets/solution_aproach.png)

- We are planning to use multi-modal models such as LLaVA or LLaVA-Med, leveraging the existing OPEA  architecture for our Q&A application. Our proposal includes a new use case where users can upload medical images (2D, 3D, 4D) for interpretation or submit a text query to find relevant images, benefiting from previous diagnoses stored in an offline system such as institutional knowledge from hospitals. Additionally, we will develop a user interface specifically designed to support these functionalities.

- Our initial strategy does not include adding new utilities to process data in the medical domain, primarily because we aim to leverage existing robust systems and focus on integrating them effectively. However, based on performance evaluations—specifically looking at accuracy, speed, and user feedback—we may consider implementing additional preprocessing or postprocessing steps. These could include image registration and/or normalization. Furthermore, should there be a need to enhance our system's efficiency, we could explore optimizations at the vector database level, potentially using VDMS (Visual Data Management System). These optimizations would aim to improve data retrieval and processing speeds, ensuring that our application meets the high demands of medical data analysis.

- We are considering the use of VDMS or Chroma for our vector database needs. The final decision will be made after a thorough benchmarking process, where we will evaluate each system's performance in handling large-scale image data. We will focus on key metrics such as retrieval speed, accuracy, and scalability. Vector database optimization is particularly crucial in our project due to the need for high precision in image similarity assessments, which are fundamental in medical imaging applications. If necessary, we will collaborate with the VDMS team to optimize performance. VDMS team has committed to providing all necessary support to ensure our application meets the required standards.

#### Use Case - 1

![image](../../assets/case_1.png)

In this scenario, the user aims to interpret a Contrast-Enhanced Spectral Mammography (CESM) image. Initially, the system searches the database for similar images and retrieves relevant diagnostic information associated with those images. This data is then utilized to construct a comprehensive prompt for the Large Multi Model (LMM). The LMM, employing advanced AI techniques, processes this prompt and generates a diagnostic interpretation, which is subsequently delivered to the user. This result not only provides an immediate analysis but also includes recommendations for further evaluation or treatment as necessary, ensuring a thorough and informed diagnostic process. Additionally, by running the data and the model on local systems equipped with robust security measures, we enhance the privacy and security of the information, aligning with stringent health data protection standards such as HIPAA and GDPR. This approach minimizes the need for expert involvement, thereby streamlining the analysis and potentially reducing operational costs without compromising diagnostic accuracy

#### Use Case - 2
<!-- ![image](../../assets/case_2.png) -->

<p align="left">
  <img src="../../assets/case_2.png" width="950" title="hover text">
</p>

In this scenario, the user specifies certain conditions, such as specific diagnostic features or patient demographics, and requests to view CESM images that meet these criteria. Initially, the system searches the database for diagnoses that match these conditions and retrieves the relevant images. These images can either be returned directly to the user or used as inputs for the Large Multi Model (LMM). If the latter option is chosen, the LMM analyzes the images to further validate their relevance to the specified conditions. Additionally, the system provides a justification for why these particular images were selected, ensuring transparency and enhancing user understanding of the process. This approach minimizes the need for expert involvement, thereby streamlining the analysis and potentially reducing operational costs.