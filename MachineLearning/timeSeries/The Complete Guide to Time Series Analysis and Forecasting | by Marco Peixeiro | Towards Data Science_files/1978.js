(self.webpackChunklite=self.webpackChunklite||[]).push([[1978],{68127:(e,t,n)=>{"use strict";n.d(t,{X:()=>E,Z:()=>w});var r=n(63038),o=n.n(r),s=n(28655),i=n.n(s),a=n(71439),c=n(67294),l=n(12291),u=n(47875),m=n(65340),d=n(88065),p=n(29355),g=n(65922),f=n(89894),x=n(80735),P=n(72955),v=n(27952);function h(){var e=i()(["\n  fragment PostListingItemRecirc_post on Post {\n    __typename\n    id\n    title\n    isLocked\n    previewImage {\n      id\n      focusPercentX\n      focusPercentY\n    }\n    ...PostByline_post\n    ...PostPresentationTracker_post\n    ...BookmarkButton_post\n    ...MultiVote_post\n    ...PostRecircItemV2_post\n  }\n  ","\n  ","\n  ","\n  ","\n  ","\n"]);return h=function(){return e},e}var E=(0,a.Ps)(h(),u.H,P.h_,d.z,p.x,m.D),_=function(e){var t=e.height,n=e.width;return{paddingBottom:"".concat(t/n*100,"%"),position:"relative"}},I={height:"100%",position:"absolute",width:"100%"},S=function(e){var t=e.title,n=e.url;return c.createElement(f.P3,{href:n},c.createElement(x.Dx,{scale:"S",tag:"h3"},t))};const w=(0,l.$j)((function(e){return{productName:e.config.productName}}))((function(e){var t,n,r=e.post,s=e.productName,i=e.target,a=c.useState(!1),l=o()(a,2),m=l[0],h=l[1],E=c.useCallback((function(e){!m&&e.isIntersecting&&h(!0)}),[m]);if((0,P.S1)({onIntersect:E,target:i,disconnect:function(){return m},rootMargin:"100px"},[m]),"SuggestedPost"===r.__typename?(t=function(e,t){var n,r,o,s;switch(e&&e[0]&&e[0].reason){case"TOP_SIMILAR_TO_POST":case"CF_POST_SIMILAR_TO_POST":return"Related reads";case"TOP_IN_TOPIC":return s=e[0].topics?e[0].topics[0].name:"topic","Popular in ".concat(s);case"POSTS_SHARING_AUTHOR":return n=e[0].users?e[0].users[0].name:"author","More from ".concat(n);case"POSTS_SHARING_TAGS":return(o=e[0].tags&&e[0].tags[0].name)?"Also tagged ".concat(o):"";case"TOP_IN_COLLECTION":return r=e[0].collections?e[0].collections[0].name:"publication","More from ".concat(r);case"TOP_FOR_THE_DAY_GLOBALLY":return"Top on ".concat(t);case"POSTS_SHARING_COLLECTION_AND_TAGS":return o=e[0].tags&&e[0].tags[0].name,r=e[0].collections?e[0].collections[0].name:"publication",o?"More on ".concat(o," from ").concat(r):"";case"RECOMMENDED_BY_AUTHOR":return(n=e[0].users&&e[0].users[0].name)?"Applause from ".concat(n):"";case"TOP_FOR_THE_DAY":return"Trending on ".concat(t);default:return"Picked for you"}}(r.postSuggestionReasons,s),n=r.post):n=r,!n)return null;var w,y,T,b,O,R,M,L=(w={id:(n.previewImage?n.previewImage.id:"")||"1*hn4v1tCaJy7cWMyb0bpNpQ.png",width:328,height:218,focusPercentX:n.previewImage?n.previewImage.focusPercentX:null,focusPercentY:n.previewImage?n.previewImage.focusPercentY:null},b=w.width,O=w.height,R=w.focusPercentX,M=w.focusPercentY,(T=w.id)?(y="number"==typeof R&&"number"==typeof M?[R,M]:[50,50],c.createElement(f.hS,null,(function(e){return c.createElement("div",{className:e(_({height:O,width:b}))},c.createElement("div",{className:e(I)},c.createElement(g.Z,{miroId:T,imgHeight:O,imgWidth:b,width:"100%",height:"100%",freezeGifs:!1,focusPercent:y})))}))):null);return c.createElement(P.ot,{post:n,presentationContext:"PLACEMENT"},c.createElement(f.xu,{md:{marginBottom:"48px"}},c.createElement(f.T5,{alignItems:{xs:"flex-start",sm:"center",md:"center",lg:"flex-start",xl:"flex-start"},direction:{xs:"row",sm:"row-reverse",md:"row-reverse",lg:"row",xl:"row"}},c.createElement(f.P4,{size:{xs:12,sm:6,md:6,lg:12,xl:12}},t&&c.createElement(f.xu,{marginBottom:"12px",md:{display:"none"},xs:{display:"block"}},c.createElement(x.F,{scale:"M"},t)),L&&c.createElement(f.xu,{marginBottom:"16px",md:{marginBottom:"0px"},xs:{marginBottom:"16px"}},c.createElement(f.rU,{display:"block",href:(0,v.jV)(n)},m?L:null))),c.createElement(f.P4,{size:{xs:12,sm:6,md:6,lg:12,xl:12}},c.createElement(f.xu,{marginBottom:"16px"},t&&c.createElement(f.xu,{display:"none",marginBottom:"4px",md:{display:"block"},xs:{display:"none"}},c.createElement(x.F,{scale:"M"},t)),c.createElement(S,{title:n.title?n.title:"",url:(0,v.jV)(n)})),c.createElement(f.xu,{display:"flex",alignItems:"center",justifyContent:"space-between"},c.createElement(f.xu,{flexShrink:"1",marginRight:"10px"},c.createElement(u.Z,{post:n,showBio:!1,scale:"S",showStar:!!n.isLocked,hideAvatar:!m})),c.createElement(f.xu,{display:"flex",alignItems:"center"},c.createElement(p.S,{post:n,buttonStyle:"SUBTLE",susiEntry:"clap_preview"}),c.createElement(f.xu,{borderRight:"BASE_LIGHTER",marginLeft:"12px",marginRight:"10px",height:"20px",width:"1px"}),c.createElement(d.e,{post:n,susiEntry:"bookmark_preview"})))))))}))},25448:(e,t,n)=>{"use strict";n.d(t,{PY:()=>p});var r=n(28655),o=n.n(r),s=n(71439),i=n(67294),a=n(12291),c=n(10515),l=n(27572),u=n(28309),m=n(81952);function d(){var e=o()(["\n  fragment EmbeddedPost_post on Post {\n    id\n    tags {\n      ...TagList_tags\n    }\n    topics {\n      topicId\n      name\n    }\n  }\n"]);return d=function(){return e},e}(0,s.Ps)(d());var p=(0,a.$j)((function(e){return{embedPostRules:e.config.embedPostRules}}))((function(e){var t=e.postId,n=e.sourcePost,r=e.embedPostRules,o=t||n&&function(e,t){var n;return e?(t.map((function(t){var r,o;return n||((null!==(r=e.topics)&&void 0!==r&&r.some((function(e){var n,r;return!(null==t||null===(n=t.topics)||void 0===n||!n.includes((null==e||null===(r=e.name)||void 0===r?void 0:r.toLowerCase())||""))}))||null!==(o=e.tags)&&void 0!==o&&o.some((function(e){var n,r;return!(null==t||null===(n=t.tags)||void 0===n||!n.includes((null==e||null===(r=e.id)||void 0===r?void 0:r.toLowerCase())||""))})))&&(n=t.embedPostId),n)})),n):n}(n,r);return o?i.createElement(m.T,{postId:o},(function(e){var t=(0,u.Iq)();return e?i.createElement(c.M.Provider,{value:!0},i.createElement(l.cW,{source:{name:"embedded_post"}},i.createElement("div",{className:t({padding:{xs:"16px 0",sm:"16px 0",md:"18px 0",lg:"24px 0",xl:"32px 0"},marginBottom:"25px"})},e))):null})):null}))},65340:(e,t,n)=>{"use strict";n.d(t,{D:()=>v,Z:()=>h});var r=n(67154),o=n.n(r),s=n(28655),i=n.n(s),a=n(71439),c=n(67294),l=n(12291),u=n(47875),m=n(61889),d=n(89894),p=n(80735),g=n(72955),f=n(90038),x=n(27952);function P(){var e=i()(["\n  fragment PostRecircItemV2_post on Post {\n    __typename\n    id\n    title\n    mediumUrl\n    previewImage {\n      id\n      focusPercentX\n      focusPercentY\n    }\n    ...PostByline_post\n    ...PostPresentationTracker_post\n  }\n  ","\n  ","\n"]);return P=function(){return e},e}var v=(0,a.Ps)(P(),u.H,g.h_);const h=(0,l.$j)((function(e){return{defaultImages:e.config.defaultImages}}))((function(e){var t,n=e.post,r=e.defaultImages,s=(null==n?void 0:n.post)||n;if(!s)return null;var i,a,l,P,v=s.title,h=s.previewImage,E=null==r||null===(t=r.postPreviewImage)||void 0===t?void 0:t.imageId,_=(l=(i={id:(null==h?void 0:h.id)||E,focusPercentX:null==h?void 0:h.focusPercentX,focusPercentY:null==h?void 0:h.focusPercentY}).focusPercentX,P=i.focusPercentY,(a=i.id)?c.createElement(m.Z,{miroId:a,freezeGifs:!1,focusPercentX:l,focusPercentY:P,strategy:f._S.Crop,width:70,height:70,otherWidths:[48,70],expectedWidth:70,rules:[{minWidth:{xs:"48px",sm:"48px",md:"48px",lg:"70px",xl:"70px"},minHeight:{xs:"48px",sm:"48px",md:"48px",lg:"70px",xl:"70px"}}]}):null);return c.createElement(g.ot,{post:s,presentationContext:"PLACEMENT"},c.createElement(d.xu,{display:"flex",justifyContent:"space-between"},c.createElement(d.xu,{flexShrink:"1",xs:{marginRight:"16px"},sm:{marginRight:"16px"},md:{marginRight:"16px"}},c.createElement(d.xu,{paddingBottom:"8px"},c.createElement(p.X6,{scale:{xs:"XXS",sm:"XXS",md:"XXS",lg:"XS",xl:"XS"}},c.createElement(d.P3,{href:(0,x.jV)(s)},v))),c.createElement(u.Z,{post:s,showBio:!1,scale:"S",detailScale:"S",showStar:!!s.isLocked,hideAvatar:!0,hideDescription:!0,noClamp:!0})),_&&c.createElement(d.xu,o()({marginLeft:"12px",marginRight:"8px"},{sm:{marginLeft:"16px",marginRight:"0px"}}),c.createElement(d.rU,{display:"block",href:(0,x.jV)(s)},_))))}))},81952:(e,t,n)=>{"use strict";n.d(t,{T:()=>f});var r=n(28655),o=n.n(r),s=n(71439),i=n(80439),a=n(67294),c=n(62630),l=n(72846);function u(){var e=o()(["\n  fragment PostContentScreen_post on Post {\n    id\n    title\n    # please note that the postMeteringOptions are defined in the postHandler file\n    content(postMeteringOptions: $postMeteringOptions) {\n      bodyModel {\n        ...PostBody_bodyModel\n      }\n    }\n    creator {\n      id\n      ...PostBody_creator\n    }\n  }\n  ","\n  ","\n"]);return u=function(){return e},e}function m(e){var t=e.post,n={bodyModel:t.content.bodyModel,creator:t.creator,postBodyInserts:null,ref:null,richTextStyle:"FULL_PAGE"};return a.createElement(l.ZP,n)}var d=(0,s.Ps)(u(),l.v,l.Pk);function p(){var e=o()(["\n  query EmbeddedPostHandler($postId: ID!, $postMeteringOptions: PostMeteringOptions) {\n    post(id: $postId) {\n      ...PostContentScreen_post\n    }\n  }\n  ","\n"]);return p=function(){return e},e}var g=(0,s.Ps)(p(),d),f=function(e){var t=e.postId,n=e.children,r=(0,c.Av)();return a.createElement(i.AE,{query:g,variables:{postId:t,postMeteringOptions:{source:null,referrer:null,sk:null}}},(function(e){var o=e.loading,s=e.error,i=e.data,c=(i=void 0===i?{}:i).post;return o?n(null):s?(r.event("embeddedPost.error",{errorMessage:s.message,postId:t}),n(null)):c?(r.event("embeddedPost.postPresented",{postId:t}),n(a.createElement(m,{post:c}))):(r.event("embeddedPost.noPost",{postId:t}),n(null))}))}}}]);
//# sourceMappingURL=https://stats.medium.build/lite/sourcemaps/1978.c2dd6520.chunk.js.map