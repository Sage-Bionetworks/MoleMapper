//
//  ReviewConsentOnlyRKModule.m
//  MoleMapper
//
//  Created by Dan Webster on 9/15/15.
// Copyright (c) 2016, OHSU. All rights reserved.
//
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
//
// 1.  Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
//
// 2.  Redistributions in binary form must reproduce the above copyright notice,
// this list of conditions and the following disclaimer in the documentation and/or
// other materials provided with the distribution.
//
// 3.  Neither the name of the copyright holder(s) nor the names of any contributors
// may be used to endorse or promote products derived from this software without
// specific prior written permission. No license is granted to the trademarks of
// the copyright holders even if such marks are included in this software.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//


#import "ReviewConsentOnlyRKModule.h"
#import "AppDelegate.h"

@interface ReviewConsentOnlyRKModule ()

@property (strong,nonatomic) ORKConsentDocument *consentDocument;

@property (strong,nonatomic) NSString *dataGatheringDetails;
@property (strong,nonatomic) NSString *privacyDetails;
@property (strong,nonatomic) NSString *dataUseDetails;
@property (strong,nonatomic) NSString *timeCommitmentDetails;
@property (strong,nonatomic) NSString *surveyDetails;
@property (strong,nonatomic) NSString *potentialBenefitsDetails;
@property (strong,nonatomic) NSString *potentialRisksDetails;
//@property (strong,nonatomic) NSString *studyTaskDetails;
@property (strong,nonatomic) NSString *protectingYourDataDetails;
@property (strong,nonatomic) NSString *issuesToConsiderDetails;
@property (strong,nonatomic) NSString *followupDetails;
@property (strong,nonatomic) NSString *withdrawDetails;
@property (strong,nonatomic) NSString *sharingStepDetails;

@end

@implementation ReviewConsentOnlyRKModule

-(ORKConsentDocument *)consentDocument
{
    if (!_consentDocument)
    {
        _consentDocument = [ORKConsentDocument new];
    }
    return _consentDocument;
}


-(void)showConsentReview
{
    
    ORKOrderedTask *task = nil;
    
    ORKConsentSection *overview =
    [[ORKConsentSection alloc] initWithType:ORKConsentSectionTypeOverview];
    overview.title = @"Consent Walkthrough";
    overview.summary = @"\nThe next few screens will explain the research study and help you decide whether or not you want to participate\n\nAfter the walkthrough, we'll briefly test your understanding to make sure you know what is involved\n";
    overview.customLearnMoreButtonTitle = @"";
    
    ORKConsentSection *dataGathering =
    [[ORKConsentSection alloc] initWithType:ORKConsentSectionTypeDataGathering];
    dataGathering.title = @"Tracking Moles";
    dataGathering.summary = @"To better understand skin health and melanoma risk, we will collect data about the moles that you have tracked in this app. This includes mole locations, mole sizes, and mole photos.";
    dataGathering.content = self.dataGatheringDetails;
    
    ORKConsentSection *privacy =
    [[ORKConsentSection alloc] initWithType:ORKConsentSectionTypePrivacy];
    privacy.title = @"Your Privacy";
    privacy.summary = @"We will make every effort to protect your privacy. We will replace your name with a random code on all of your study data. However, total anonymity cannot be guaranteed.";
    privacy.content = self.privacyDetails;
    
    ORKConsentSection *dataUse =
    [[ORKConsentSection alloc] initWithType:ORKConsentSectionTypeDataUse];
    dataUse.title = @"Data Use";
    dataUse.summary = @"We will add your data (without your name) to those of other study participants and look for clues to explain mole measurements and melanoma risks";
    dataUse.content = self.dataUseDetails;
    
    ORKConsentSection *timeCommitment =
    [[ORKConsentSection alloc] initWithType:ORKConsentSectionTypeTimeCommitment];
    timeCommitment.title = @"Time Commitment";
    timeCommitment.summary = @"The initial sign up and questions will take about 5-10 minutes. Monthly follow-ups will include a 1-minute survey and an update of your mole measurements (about 1 minute each)";
    timeCommitment.content = self.timeCommitmentDetails;
    
    ORKConsentSection *studySurvey =
    [[ORKConsentSection alloc] initWithType:ORKConsentSectionTypeStudySurvey];
    studySurvey.title = @"Study Questions";
    studySurvey.summary = @"First we will ask you a few questions about yourself and about potential melanoma risks. Monthly follow-up questions will focus on sun exposure and your health. You can skip any questions you do not wish to answer.";
    studySurvey.content = self.surveyDetails;
    studySurvey.customLearnMoreButtonTitle = @"Learn more about the study questions";
    
    ORKConsentSection *benefits =
    [[ORKConsentSection alloc] initWithType:ORKConsentSectionTypeStudyTasks];
    benefits.title = @"Potential Benefits";
    benefits.summary = @"Your participation could help us understand the underlying causes of melanoma. You will be able to visualize and track your own data and potentially learn more about trends in your health.";
    benefits.content = self.potentialBenefitsDetails;
    benefits.customLearnMoreButtonTitle = @"Learn more about the potential benefits";
    
    ORKConsentSection *risks =
    [[ORKConsentSection alloc] initWithType:ORKConsentSectionTypeWithdrawing];
    risks.title = @"Potential Risks";
    risks.summary = @"Participation in this study may involve risks to your privacy and other risks that are not known at this time.";
    risks.content = self.potentialRisksDetails;
    risks.customLearnMoreButtonTitle = @"Learn more about the potential risks";
    
    ORKConsentSection *secure = [[ORKConsentSection alloc] initWithType:ORKConsentSectionTypeCustom];
    secure.title = @"Protecting Your Data";
    secure.summary = @"Your study data will be encrypted on the phone and stored, without your name, on a secure cloud server.";
    secure.customImage = [UIImage imageNamed:@"secureDatabase"];
    secure.content = self.protectingYourDataDetails;
    secure.customLearnMoreButtonTitle = @"Learn more about data protection";
    secure.customAnimationURL = [[NSBundle mainBundle] URLForResource: @"secureDatabase@2x" withExtension:@"m4v"];
    
    ORKConsentSection *issues = [[ORKConsentSection alloc] initWithType:ORKConsentSectionTypeCustom];
    issues.title = @"Issues to Consider";
    issues.summary = @"Mole Mapper doesn’t replace your medical care. It is a research study and doesn’t provide diagnosis or treatment recommendations.";
    issues.customImage = [UIImage imageNamed:@"visitingDoctor"];
    issues.content = self.issuesToConsiderDetails;
    issues.customLearnMoreButtonTitle = @"Learn more about issues to consider";
    issues.customAnimationURL = [[NSBundle mainBundle] URLForResource: @"visitingDoctor@2x" withExtension:@"m4v"];
    
    ORKConsentSection *recontact = [[ORKConsentSection alloc] initWithType:ORKConsentSectionTypeCustom];
    recontact.title = @"Follow Up";
    recontact.summary = @"Your name and contact information will be included in the OHSU War on Melanoma Community Registry. You can opt out of this registry at any time.";
    recontact.customImage = [UIImage imageNamed:@"recontact"];
    recontact.content = self.followupDetails;
    recontact.customLearnMoreButtonTitle = @"Learn more about follow up";
    recontact.customAnimationURL = [[NSBundle mainBundle] URLForResource: @"recontact@2x" withExtension:@"m4v"];
    
    ORKConsentSection *withdraw =
    [[ORKConsentSection alloc] initWithType:ORKConsentSectionTypeCustom];
    withdraw.title = @"Withdraw at any time";
    withdraw.summary = @"Your participation is voluntary. You may withdraw at any time.";
    withdraw.customImage = [UIImage imageNamed:@"withdraw"];
    withdraw.content = self.withdrawDetails;
    
    self.consentDocument.sections = @[overview,dataGathering,privacy,dataUse,timeCommitment,studySurvey,benefits,risks,secure,issues,recontact,withdraw];
    
    ORKVisualConsentStep *visualConsentStep =
    [[ORKVisualConsentStep alloc] initWithIdentifier:@"visualConsent" document:self.consentDocument];
    
    self.consentDocument.title = @"Research Consent";
    self.consentDocument.signaturePageTitle = @"Participant Signature";
    self.consentDocument.signaturePageContent = @"Providing your signature is the final step to consenting to your participation in this research study";
    
    task = [[ORKOrderedTask alloc] initWithIdentifier:@"task" steps:@[visualConsentStep]];
    ORKTaskViewController *taskViewController = [[ORKTaskViewController alloc] initWithTask:task taskRunUUID:nil];
    taskViewController.delegate = self;
    [self.presentingVC presentViewController:taskViewController animated:YES completion:nil];
}

- (void)taskViewController:(ORKTaskViewController *)taskViewController
       didFinishWithReason:(ORKTaskViewControllerFinishReason)reason
                     error:(NSError *)error
{
    
    //ORKTaskResult *taskResult = [taskViewController result];
    
    switch (reason)
    {
        case ORKTaskViewControllerFinishReasonCompleted:
        {
            break;
        }
            
        case ORKTaskViewControllerFinishReasonFailed:
        {
            break;
        }
        case ORKTaskViewControllerFinishReasonDiscarded:
        {
            break;
        }
            
        case ORKTaskViewControllerFinishReasonSaved:
        {
            break;
        }
    }
    // Then, dismiss the task view controller.
    [self.presentingVC dismissViewControllerAnimated:YES completion:nil];
    [self.presentingVC.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Learn more text

-(NSString *)dataGatheringDetails
{
    return @"If you join this research study we will ask you to share your mole measurements collected using Mole Mapper. You will:\n\n1- Take pictures of your moles with your smartphone camera,\n2- Map them to zones on the Mole Mapper body map\n3- Measure their size relative to a reference object like a coin photographed next to the mole.\n\nWe will prompt you to re-measure your moles each month and send your updated data along with any information about new moles and whether you had any moles removed. If you have had a mole removed in a given month, we will ask you to take a photo and measurement of the biopsy site.\n\nYou can track your moles at your convenience, track more or fewer moles or stop sharing your mole measurements at any time.";
}

-(NSString *)privacyDetails
{
    return @"Your privacy is important to us.\n\nThe data collected through the app will be encrypted on the phone.\n\nWe will separate your account information (name, email, contact information, etc.) from the study data (the responses to surveys, the mole pictures and the mole measurements). The metadata will consist of your responses to survey and mole measurements only.  No mole pictures will be included in the metadata.\n\nWe will use a random code instead of your name on all study data.  This code cannot be used to directly re-identify you.  Information about the code will be kept in a separate secure system.  Only key personnel from the study team may connect your study data to your name and account information.\n\nSancy Leachman, MD. PhD, is leading the study teams for both Mole Mapper Study and the War on Melanoma™ Community Registry.\n\nThe photos you take using Mole Mapper are stored within the app, not on your phone's photostream or other cloud storage system.\n\nWe will not access your personal phone contacts, other applications, personal photos, texts, emails or websites visited.\n\nPlease consult our Privacy Policy for more details.";
}

-(NSString *)dataUseDetails
{
    return @"Your un-named and coded study data (the answers you provide on surveys and your mole data, including mole measurements and mole photos) will be combined with the similarly de-identified data from other study participants.\n\nBy analyzing the data from many Mole Mapper app users we hope to better understand the variation in mole growth and cancer risks, and whether a mobile device can help people better measure moles accurately and manage skin health.\n\nFor example, airline pilots and flight crew are about 2 times more likely to develop melanoma. But does this also mean that they have 2 times more moles, or experience more dynamic mole changes that can be caught early? Large, combined data sets are necessary to answer these types of questions.\n\nThe OHSU study team may query the data to identify and re-contact people with certain mole characteristics, and invite them to join specific melanoma-related opportunity or events that may be of interest to them through the War on Melanoma Community Registry.\n\nYour information will not be used for commercial advertising.";
}

-(NSString *)timeCommitmentDetails
{
    return @"This study involves answering survey questions and sending mole measurements and photos that you have taken.\n\nWe will send notices on your phone to re-measure your tracked moles every month and send your updated data along with any information about new moles and whether you had any moles removed.\n\nThe initial survey may take 5-10 minutes, and the follow-up surveys are expected to take about 1 minute. Measuring a mole may take 1-2 minutes per mole.  You can stop and restart where you left off at any time.\n\nFor most people, participating in this study will take no more than 20 minutes per month.  You can adjust your level of participation, as you desire.  The number of moles you track and how often you track you moles is entirely up to you.\n\nTransmitting data collected in this study may count against your existing mobile data plan.  You may configure the application to only use WiFi connections to limit the impact this data collection has on your data plan.";
}


-(NSString *)surveyDetails
{
    return @"We will ask you questions, such as your profession, zip code where you live, hair/skin color and your prior experience with melanoma. These questions will be used to evaluate your exposure to UV radiation and your melanoma risk.  Each month we will also ask you questions about your sun exposure, your health and whether you had moles removed.\n\nYou can skip any questions you do not wish to answer.";
}

-(NSString *)potentialBenefitsDetails
{
    return @"This project could create the largest dataset of longitudinal tracking of moles and may provide insights into the progression of moles to melanoma.\n\nYou may or may not personally benefit from this study. However, using the Mole Mapper app may help you monitor your moles over time. You will be able to share your mole photos and measurements as you wish, with your medical doctor and anyone you choose. You will also receive alerts about future melanoma educational and community events, free skin cancer screenings and/or skin cancer research opportunities from the War on Melanoma Community Registry.";
}

-(NSString *)potentialRisksDetails
{
    return @"We take great care to protect your information, however there is a slight risk of loss of privacy. This risk is low because we separate your account information (name, email, contact information, etc.) from the study data. Only key members of the study team and some IT staff will have the key to associate your coded study data to your name and account information.\n\nHowever, certain skin features like tattoos or birthmarks may be unique to you and enable your re-identification. So even through your name is kept separate from your coded study data, it is possible that someone could still figure out your identity.  To reduce this risk we recommend photographing moles at close range (6 inches from skin surface) to minimize capture of secondary identifiable skin features. Further, we will attempt to review and remove from the study dataset all photos that we consider identifiable or inappropriate for broad sharing with the research community.\n\nThe risk to privacy and confidentiality should be considered before participating in the study.";
}

-(NSString *)protectingYourDataDetails
{
    return @"We will use strict information technology procedures to safeguard your data and prevent improper access.\n\nYour data will be stored by our vendor Sage Bionetworks and OHSU on separate secure Cloud servers in a manner that keeps your information as safe as possible and prevents unauthorized people from getting to your data.\n\nYour coded study data may be shared with researchers in other countries, including countries that may have different data protection laws than your country of residence.";
}

-(NSString *)issuesToConsiderDetails
{
    return @"This study will NOT provide you with information related to your specific health or melanoma risks.\n\nThis is NOT a medical diagnostic tool and isn’t designed to provide medical advice, professional diagnosis, opinion, treatment or healthcare services.\n\nYou should not use the information provided in Mole Mapper or the study documentation in place of a consultation with your physician or health care provider.\n\nIf you have any questions or concerns related to your health, you should seek the advice of a medical professional.";
}

-(NSString *)followupDetails
{
    return @"The study team may re-contact you. Your name, contact information and your unique healthCode will be added to the War on Melanoma™ Community Registry that was created by researchers at Oregon Health & Science University. The War on Melanoma Community Registry is a confidential registry for melanoma patients, family members and friends determined to find answers and reduce deaths caused by melanoma.\n\nBy joining the registry you can help researchers figure out how best to prevent, treat and detect melanoma. You will receive information about upcoming events in your community and get notified about future melanoma education and research opportunities.\n\nWAR ON MELANOMA COMMUNITY REGISTRY\nYou are invited to join a registry of melanoma patients, their families and friends. The Melanoma Community Registry will serve as a resource for communicating with you about future melanoma community outreach projects and research that may be of interest to you. By agreeing to be included in the Melanoma Community Registry, you are providing consent or permission for OHSU researchers to keep information you provide to the Melanoma Community Registry in a confidential, privacy-protected, ethics board-approved database. You are authorizing them to contact you in the future regarding other melanoma educational and community events, free skin cancer screenings, and/or skin cancer research opportunities. Your participation in any of these events is completely voluntary and you can request removal from the registry at any time.\n\nHOW MANY PEOPLE WILL TAKE PART IN THIS REGISTRY?\nAs many as 100,000 people will take part in this registry, which will be managed by Oregon Health & Science University.\n\nWHAT WILL HAPPEN IF I TAKE PART IN THIS RESEARCH REGISTRY?\nThe information you choose to provide will help researchers learn about melanoma. The amount of information you provide the registry is up to you. In addition to your contact information, OHSU may ask you to fill out optional questionnaires and provide other information about your health.  All data included in the Melanoma Community Registry will be stored in a secure database maintained by OHSU.  With your permission, researchers from OHSU may also access information about you stored in other databases (e.g. data collected through the Mole Mapper App research collaboration between OHSU and Sage Bionetworks).\n\nResearchers outside of OHSU may ask the Department of Dermatology to contact you about research studies they are conducting.  In this case, OHSU researchers will contact you on their behalf (the researchers will not be given your contact information unless you directly provide it to them) so that you can decide if you’d like to participate in that future research.  If you decide you do want to participate you will be given the information necessary to contact the researchers directly. Only studies relevant to melanoma, approved by an ethics board, and reviewed by the OHSU study team will be eligible to use this registry for research.\n\nBefore you agree to participate in any future research, the investigator must tell you:\nWhy the research is being done, what you will have to do, and how long it will last;\nThe risks and benefits of the research;\nWhat other choices you have if you prefer not to join the research study; and,\nHow information about you will be protected.\n\nDepending on the study, the investigator may also tell you about:\nWhat will happen if you are harmed by the study;\nWhat happens if you decide to stop participating in the study;\nNew risks that may be discovered during the study;\nThe reason(s) why you may be asked to leave the study before it is completed;\nCosts, if any, you may responsible for; and\nHow many people will be in the study.\n\nHOW LONG WILL I BE IN THE REGISTRY?\nYour information will be stored indefinitely, unless you request to be removed from the registry.\n\nWHAT ABOUT COMMERCIAL DEVELOPMENT?\nInformation provided, including any survey responses, photographs, videotapes, or audiotapes about you or obtained from you as part of the Melanoma Community Registry, may be used for commercial purposes, such as making a discovery that could, in the future, be patented or licensed to a company, which could result in a possible financial benefit to that company, OHSU, and its researchers. There are no plans to pay you if this happens. You will not have any property rights or ownership or financial interest in or arising from products or data that may result from your participation in this study.  Further, you will have no responsibility or liability for any use that may be made of your samples or information.\n\nWHAT RISKS CAN I EXPECT FROM BEING IN THE REGISTRY?\nWe take significant precautions to protect your information included in the Melanoma Community Registry. All of the information you provide to the Melanoma Community Registry is stored at OHSU on a secure, HIPAA-compliant server. However, there is a small risk of loss of confidentiality.  If the information in this registry were to be accidentally released, it might be possible that the information we will gather about you as part of this registry could become available to others.\n\nIf you are injured or harmed while participating in the Melanoma Community Registry or while using the cellphone application for the Mole Mapper Study, you will be treated. OHSU does not offer any financial compensation or payment for the cost of treatment if you are injured or harmed as a result of participating in this research. Therefore, any medical treatment you need may be billed to you or your insurance. However, you are not prevented from seeking to collect compensation for injury related to negligence on the part of those involved in the research. Oregon law (Oregon Tort Claims Act (ORS 30.260 through 30.300)) may limit the dollar amount that you may recover from OHSU or its caregivers and researchers for a claim relating to care or research at OHSU, and the time you have to bring a claim.\n\nIf you have questions on this subject, please call the OHSU Research Integrity Office at (503) 494-7887.\n\nARE THERE BENEFITS TO TAKING PART IN THE REGISTRY?\nYou may or may not personally benefit from being in this registry.  However, by serving as a participant, you may help us learn how to benefit patients in the future.\n\nWHAT OTHER CHOICES DO I HAVE IF I DO NOT TAKE PART IN THIS REGISTRY?\nYou may choose not to be in this registry.\n\nWILL MY INFORMATION BE KEPT PRIVATE?\nWe will take steps to keep your personal information confidential, but we cannot guarantee total privacy.\n\nWHAT ARE THE COSTS OF TAKING PART IN THIS REGISTRY?\nThere will be no cost to you or your insurance company to participate in this registry.\n\nWHAT ARE MY RIGHTS IF I TAKE PART IN THIS REGISTRY?\nIf you have any questions regarding your rights as a research participant, you may contact the OHSU Research Integrity Office at (503) 494-7887.\n\nYou do not have to join this or any research study.  If you do join the registry and later change your mind, you have the right to withdraw at any time.  This includes the right to withdraw your authorization to use and disclose your health information.\n\nWHAT WILL HAPPEN IF I CHOOSE TO STOP PARTICIPATING IN THE REGISTRY?\nYou can decide to stop at any time.  If, in the future, you decide you no longer want to participate in this registry, we will delete your information from the Melanoma Community Registry.  However, if your information is already being used in an on-going research project and if its withdrawal jeopardizes the success of the entire project, we may continue to use it until the project is completed.";
}

-(NSString *)studyTaskDetails
{
    return @"As part of this study, you will be asked to take pictures of zones (corresponding to the MoleMapper bodymap). You will be asked to drop “pins” to indicate where the moles are within that zone. You will also be asked to measure your moles against a reference object (such as a coin). We will prompt you to re-measure your tracked moles every month and send your updated data along with a short follow-up survey. If you have a mole removed, we will ask which mole was removed and ask you to take a photo of this location after the biopsy. You are encouraged to document as many zones and moles as you’d like. The more you measure, the better.";
}

-(NSString *)withdrawDetails
{
    return @"You may decide not to participate in the study or you may leave the study and/or the War on Melanoma™ Community Registry at any time.\n\nYou can continue using the Mole Mapper app after you leave the study.\n\nIf you withdraw from the study, we will stop collecting new data. The coded study data collected prior to withdrawing may still be used in the study, it will not be destroyed or deleted.\n\nThe study team may also withdraw you from the study at any time for any reason.\n\nTo withdraw from the Mole Mapper study and the War on Melanoma™ Community Registry,please use the ‘Leave Study’ button on the Profile page of the Mole Mapper app.";
}

-(NSString *)sharingStepDetails
{
    return @"This study gives you the option to share your data in 2 ways:\n\n1- Share with the research world (“Share broadly”):  You can choose to share your study data with the study team and its partners and your coded study data with qualified researchers worldwide for use in this research and beyond.  Coded study data is data that does not include personal information such as your name or email. Qualified researchers are registered users of Synapse who have agreed to use the data in an ethical manner for research purposes, and have agreed to not attempt to re-identify you.  If you choose to share your coded study data, the metadata (your response to survey questions and the mole measurements without the mole photo) will be added to a shared dataset available to qualified researchers on the Sage Bionetworks Synapse servers at synapse.org.  Your mole photos will be available to qualified researchers who have received ethical approval to use the photos for their research.  Sage Bionetworks will have no oversight on the future research that qualified researchers may conduct with the coded study data.\n\n2- Only share with the study team (“Share sparsely”): You can choose to share your study data only with the study team and its partners.  The study team includes the Principal Investigator of the research and any other researchers or partners named in the consent document. Sharing your study data this way means that your data will not be made available to anyone other than those listed in the consent document for the purposes of this study, and to be part of and to be part of the OHSU War on Melanoma Community Registry.\n\nIf required by law, your study data, account information and the signed consent form may be disclosed to:\nThe US Department of Health and Human Services, the Office for Human Research Protection, and other agencies for verification of the research procedures and data.\nInstitutional Review Board who monitors the safety, effectiveness and conduct of the research being conducted\n\nThe results of this research study may be presented at meetings or in publications. If the results of this study are made public, only coded study data and de-identified mole photos will be used, that is, your personal information will not be disclosed.\n\nYou can change the data sharing setting though the app preference at anytime.  For additional information review the study privacy policy";
}


@end
