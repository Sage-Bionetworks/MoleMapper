//
//  ReviewConsentOnlyRKModule.m
//  MoleMapper
//
//  Created by Dan Webster on 9/15/15.
//  Copyright (c) 2015 Webster Apps. All rights reserved.
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
    return @"If you join this research study we will ask you to share your mole measurements collected using Mole Mapper. You will:\n\n1- Take pictures of your moles with the iPhone camera,\n2- Map them to zones on the Mole Mapper body map\n3- Measure their size relative to a reference object like a coin photographed next to the mole.\n\nWe will prompt you to re-measure your moles each month and send your updated data along with any information about new moles and whether you had any moles removed. If you have had a mole removed in a given month, we will ask you to take a photo and measurement of the biopsy site.\n\nYou can track your moles at your convenience, track more or fewer moles or stop sharing your mole measurements at any time.";
}

-(NSString *)privacyDetails
{
    return @"Your privacy is important to us.\n\nThe data collected through the app will be encrypted on the phone.\n\nWe will separate your account information (name, email, contact information, etc.) from the study data (the responses to surveys, the mole pictures and the mole measurements). The metadata will consist of your responses to survey and mole measurements only.  No mole pictures will be included in the metadata.\n\nWe will use a random code instead of your name on all study data.  This code cannot be used to directly re-identify you.  Information about the code will be kept in a separate secure system.  Only key personnel from the study team may connect your study data to your name and account information.\n\nDr. Stephen Friend, MD. PhD, Sage Bionetworks (nonprofit) is leading the study team composed of researchers from Sage Bionetworks and from the War on Melanoma Community Registry (OHSU). Dr. Sancy Leachman is the principal investigator for the War on Melanoma Community Registry.\n\nThe photos you take using Mole Mapper are stored within the app, not on your phone photostream.\n\nWe will not access your personal phone contacts, other applications, personal photos, texts, emails or websites visited.\n\nPlease consult our Privacy Policy for more details.";
}

-(NSString *)dataUseDetails
{
    return @"Your un-named and coded study data (the answers you provide on surveys and your mole data, including mole measurements and mole photos) will be combined with the similarly de-identified data from other study participants.\n\nBy analyzing the data from many app users we hope to better understand the variation in mole growth and cancer risks, and whether a mobile device can help better measure moles and manage skin health.\n\nFor example, airline pilots and flight crew are about 2 times more likely to develop melanoma. But does this also mean that they have 2 times more moles, or experience more dynamic mole changes that can be caught early? Large, combined data sets are necessary to answer these types of questions.\n\nThe study team may query the data to identify and re-contact people with certain mole characteristics, and invite them to join specific melanoma-related opportunity or events that may be of interest to them through the War on Melanoma registry.  Sage Bionetworks isn’t involved in the development, maintenance and implementation of the WoM Community registry and will not have oversight on communications to or from the registry.\n\nYour information will not be used for commercial advertising.";
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
    return @"This project could create the largest dataset of longitudinal tracking of moles and may provide insights into the progression of moles to melanoma.\n\nWe cannot, and thus we do not, guarantee or promise that you will personally receive any direct benefits from this study.  However, using the Mole Mapper app may help you monitor your moles over time. You will be able to share your mole photos and measurements as you wish, with your medical doctor and anyone you choose. You will also receive alerts about future melanoma educational and community events, free skin cancer screenings and/or skin cancer research opportunities from the War on Melanoma community registry.";
}

-(NSString *)potentialRisksDetails
{
    return @"We take great care to protect your information, however there is a slight risk of loss of privacy. This risk is low because we separate your account information (name, email, contact information, etc.) from the study data. Only key members of the study team and some IT staff will have the key to associate your coded study data to your name and account information.\n\nHowever, certain skin features like tattoos or birthmarks may be unique to you and enable your re-identification. So even through your name is kept separate from your coded study data, it is possible that someone could still figure out your identity.  To reduce this risk we recommend photographing moles at close range (6 inches from skin surface) to minimize capture of secondary identifiable skin features. Further, we will attempt to review and remove from the study dataset all photos that we consider identifiable or inappropriate for broad sharing with the research community.\n\nThe risk to privacy and confidentiality should be considered before participating in the study.";
}

-(NSString *)protectingYourDataDetails
{
    return @"We will use strict information technology procedures to safeguard your data and prevent improper access.\n\nYour study data will be store on a secure Cloud server in a manner that keeps your information as safe as possible and prevents unauthorized people from getting to your data.\n\nYour coded study data may be shared with researchers in other countries, including countries that may have different data protection laws than your country of residence.";
}

-(NSString *)issuesToConsiderDetails
{
    return @"This study will NOT provide you with information related to your specific health or melanoma risks.\n\nThis is NOT a medical diagnostic tool and isn’t designed to provide medical advice, professional diagnosis, opinion, treatment or healthcare services.\n\nYou should not use the information provided in Mole Mapper or the study documentation in place of a consultation with your physician or health care provider.\n\nIf you have any questions or concerns related to your health, you should seek the advice of a medical professional.";
}

-(NSString *)followupDetails
{
    return @"The study team may re-contact you. By default your names, contact information and your unique healthCode will be added to the War on Melanoma Community Registry that was created by researchers at Oregon Health & Science University and co-investigators in the Mole Mapper study.\n\nThe War on Melanoma Community Registry is a confidential registry for melanoma patients, family members and friends determined to find answers and reduce deaths caused by melanoma.\n\nBy joining the registry you can help researchers figure out how best to prevent, treat and detect melanoma by answering more surveys about your melanoma diagnosis.  You can request information about upcoming events in your community and get notified about future melanoma education and research opportunities.\n\nTo opt-out of the registry please contact the registry personnel at 1-844-300-SPOT (7768) or WarOnMelanoma@ohsu.edu.";
}

-(NSString *)studyTaskDetails
{
    return @"As part of this study, you will be asked to take pictures of zones (corresponding to the MoleMapper bodymap). You will be asked to drop “pins” to indicate where the moles are within that zone. You will also be asked to measure your moles against a reference object (such as a coin). We will prompt you to re-measure your tracked moles every month and send your updated data along with a short follow-up survey. If you have a mole removed, we will ask which mole was removed and ask you to take a photo of this location after the biopsy. You are encouraged to document as many zones and moles as you’d like. The more you measure, the better. ";
}

-(NSString *)withdrawDetails
{
    return @"You may decide not to participate in the study or you may leave the study and/or the War on Melanoma registry at any time.\n\nYou can continue using the Mole Mapper app after you leave the study.\n\nIf you withdraw from the study, we will stop collecting new data.  The coded study data collected prior to withdrawing may still be used in the study, it will not be destroyed or deleted.\n\nThe study team may also withdraw you from the study at any time for any reason.\n\nTo withdraw from the Mole Mapper study, please contact the study team by email  molemapperstudy@sagebase.org or you can uninstall the Mole Mapper app from your device.\n\nTo withdraw from the War on Melanoma Community registry please contact the registry personnel at 1-844-300-SPOT (7768) or WarOnMelanoma@ohsu.edu.";
}

-(NSString *)sharingStepDetails
{
    return @"This study gives you the option to share your data in 2 ways:\n\n1- Share with the research world:  You can choose to share your coded study data with qualified researchers worldwide for use in this and future academic and commercial research.  Coded study data is data that does not include personal information such as your name or email. Qualified researchers are registered users of Synapse who have agreed to use the data in an ethical manner for research purposes, and have agreed to not attempt to re-identify you.  If you choose to share your coded study data broadly, the metadata (your response to survey questions and the mole measurements without the mole photo) will be added to a shared dataset available to qualified researchers on the Sage Bionetworks Synapse servers at synapse.org.  Your mole photos will be available to qualified researchers who have received ethical approval to use the photos for their research.  Sage Bionetworks will have no oversight on the future research that qualified researchers may conduct with the coded study data.\n\n2- Only share with the study team: You can choose to share your study data only with the study team and its partners.  The study team includes the sponsor of the research and any other researchers or partners named in the consent document. Sharing your study data this way means that your data will not be made available to anyone other than those listed in the consent document and for the purposes of this study only. Note that your name and contact information will be included in the OHSU War on Melanoma Community Registry.\n\nIf required by law, your study data, account information and the signed consent form may be disclosed to:\n-The US Department of Health and Human Services, the Office for Human Research Protection, and other agencies for verification of the research procedures and data.\n-Institutional Review Board who monitors the safety, effectiveness and conduct of the research being conducted,The results of this research study may be presented at meetings or in publications. If the results of this study are made public, only coded study data and de-identified mole photos will be used, that is, your personal information will not be disclosed.\n\nYou can change the data sharing setting though the app preference at anytime.  For additional information review the study privacy policy.";
}


@end
